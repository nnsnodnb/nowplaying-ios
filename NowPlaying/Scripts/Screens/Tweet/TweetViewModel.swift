//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import FirebaseAnalytics
import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import SwifteriOS

struct TweetViewModelInput {

    let iconImageButton: Observable<Void>
    let addImageButton: Observable<Void>
    let postContent: PostContent
    let textViewText: Observable<String>
}

// MARK: - TweetViewModelOutput

protocol TweetViewModelOutput {

    var isPostable: Observable<Bool> { get }
    var user: Observable<User> { get }
    var successRequest: Observable<Void> { get }
    var failureRequest: Observable<Error> { get }
}

// MARK: - TweetViewModelType

protocol TweetViewModelType {

    var outputs: TweetViewModelOutput { get }

    init(inputs: TweetViewModelInput)
    func getDefaultAccount()
    func preparePost()
    func preparePost(withImage image: UIImage)
}

final class TweetViewModel: TweetViewModelType {

    var outputs: TweetViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let postContent: PostContent
    private let postMessage: BehaviorRelay<String>
    private let postUser: BehaviorRelay<User>
    private let tweetStatusAction: Action<(SecretCredential, String, Data?), JSON>
    private let tootStatusOnlyTextAction: Action<(SecretCredential, String), Void>
    private let tootUploadMediaAction: Action<(SecretCredential, Data), MastodonMediaResponse>
    private let tootStatusWithMediaAction: Action<(SecretCredential, String, [String]), Void>
    private let _success = PublishRelay<Void>()
    private let _failure = PublishRelay<Error>()

    private var secretCredential: SecretCredential {
        return postUser.value.secretCredentials.first!
    }

    init(inputs: TweetViewModelInput) {
        let realm = try! Realm(configuration: realmConfiguration)

        let defaultUser = realm.objects(User.self)
            .filter("serviceType = %@ AND isDefault = %@", inputs.postContent.service.rawValue, true)
            .first!
        postUser = BehaviorRelay<User>(value: defaultUser)

        postContent = inputs.postContent
        postMessage = BehaviorRelay<String>(value: inputs.postContent.postMessage)

        // テキストのみ・メディア込みポストアクション (Twitter)
        tweetStatusAction = Action {
            return TwitterPostRequest(credential: $0.0).postTweet(status: $0.1, media: $0.2)
        }
        // テキストのみのポストアクション (Mastodon)
        tootStatusOnlyTextAction = Action {
            return Session.shared.rx.response(MastodonTootRequest(secret: $0.0, status: $0.1))
        }
        // メディアアップロードアクション (Mastodon)
        tootUploadMediaAction = Action {
            return Session.shared.rx.response(MastodonMediaRequest(secret: $0.0, imageData: $0.1))
        }
        // メディアこみのポストアクション (Mastodon)
        tootStatusWithMediaAction = Action {
            return Session.shared.rx.response(MastodonTootRequest(secret: $0.0, status: $0.1, mediaIDs: $0.2))
        }

        subscribeInputs(inputs)
        subscribeAction()
    }

    func getDefaultAccount() {
        postUser.accept(postUser.value)
    }

    func preparePost() {
        switch postContent.service {
        case .twitter:
            tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, nil))
            Analytics.Tweet.postTweetTwitter(withHasImage: false, content: postContent)
        case .mastodon:
            tootStatusOnlyTextAction.inputs.onNext((secretCredential, postMessage.value))
            Analytics.Tweet.postTootMastodon(withHasImage: false, content: postContent)
        }
    }

    func preparePost(withImage image: UIImage) {
        switch postContent.service {
        case .twitter:
            guard let imageData = image.pngData() else {
                _failure.accept(NSError(domain: "moe.nnsnodnb.NowPlaying", code: 400, userInfo: ["detail": "画像が見つかりません"]))
                return
            }
            tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, imageData))
            Analytics.Tweet.postTweetTwitter(withHasImage: true, content: postContent)
        case .mastodon:
            guard let imageData = image.pngData() else {
                _failure.accept(NSError(domain: "moe.nnsnodnb.NowPlaying", code: 400, userInfo: ["detail": "画像が見つかりません"]))
                return
            }
            tootUploadMediaAction.inputs.onNext((secretCredential, imageData))
            Analytics.Tweet.postTootMastodon(withHasImage: true, content: postContent)
        }
    }
}

// MARK: - Private method

extension TweetViewModel {

    private func subscribeInputs(_ inputs: TweetViewModelInput) {
        inputs.textViewText
            .bind(to: postMessage)
            .disposed(by: disposeBag)

        inputs.iconImageButton
            .subscribe(onNext: {
                // TODO: アカウント切り替え画面表示
            })
            .disposed(by: disposeBag)

        inputs.addImageButton
            .subscribe(onNext: {
                // TODO: アートワークかスクショにする選択するアクションシート (Must: アートワーク)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeAction() {
        tweetStatusAction.elements
            .map { _ in }
            .subscribe(onNext: { [weak self] in
                self?._success.accept(())
            }, onError: { [weak self] (error) in
                self?._failure.accept(error)
            })
            .disposed(by: disposeBag)

        tootStatusOnlyTextAction.elements
            .subscribe(onNext: { [weak self] in
                self?._success.accept(())
            }, onError: { [weak self] (error) in
                self?._failure.accept(error)
            })
            .disposed(by: disposeBag)

        tootUploadMediaAction.elements
            .subscribe(onNext: { [weak self] (response) in
                guard let wself = self else { return }
                wself.tootStatusWithMediaAction.inputs.onNext((wself.secretCredential, wself.postMessage.value, [response.mediaID]))
            }, onError: { [weak self] (error) in
                self?._failure.accept(error)
            })
            .disposed(by: disposeBag)

        tootStatusWithMediaAction.elements
            .subscribe(onNext: { [weak self] in
                self?._success.accept(())
            }, onError: { [weak self] (error) in
                self?._failure.accept(error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TweetViewModelType

extension TweetViewModel: TweetViewModelOutput {

    var isPostable: Observable<Bool> {
        return postMessage
            .map { !$0.isEmpty }
            .observeOn(MainScheduler.instance)
            .asObservable()
    }

    var user: Observable<User> {
        return postUser.asObservable()
    }

    var successRequest: Observable<Void> {
        return _success.observeOn(MainScheduler.instance).asObservable()
    }

    var failureRequest: Observable<Error> {
        return _failure.observeOn(MainScheduler.instance).asObservable()
    }
}
