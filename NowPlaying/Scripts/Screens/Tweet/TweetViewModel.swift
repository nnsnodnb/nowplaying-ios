//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Feeder
import FirebaseAnalytics
import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import Swifter

struct TweetViewModelInput {

    let postContent: PostContent
}

// MARK: - TweetViewModelOutput

protocol TweetViewModelOutput {

    var postResult: Observable<Void> { get }
}

// MARK: - TweetViewModelType

protocol TweetViewModelType {

    var outputs: TweetViewModelOutput { get }

    init(inputs: TweetViewModelInput)
    func getCurrentAccount()
    func preparePost(image: UIImage?)
}

final class TweetViewModel: TweetViewModelType {

    var outputs: TweetViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let postContent: PostContent
    private let postMessage: BehaviorRelay<String>
    private let postUser: BehaviorRelay<User>
    private let tweetStatusAction: Action<(SecretCredential, String, Data?), JSON>
    private let tootStatusAction: Action<(SecretCredential, String, [String]?), Void>
    private let tootUploadMediaAction: Action<(SecretCredential, Data), MastodonMediaResponse>
    private let _postResult = PublishSubject<Void>()

    private var secretCredential: SecretCredential {
        return postUser.value.secretCredentials.first!
    }

    init(inputs: TweetViewModelInput) {
        let defaultUser = User.getDefaultUser(service: inputs.postContent.service)!
        postUser = BehaviorRelay<User>(value: defaultUser)

        postContent = inputs.postContent
        postMessage = BehaviorRelay<String>(value: inputs.postContent.postMessage)

        // テキストのみ・メディア込みポストアクション (Twitter)
        tweetStatusAction = Action {
            return TwitterPostRequest(credential: $0.0).postTweet(status: $0.1, media: $0.2)
        }
        // テキストのみ・メディア込みポストアクション (Mastodon)
        tootStatusAction = Action {
            return Session.shared.rx.response(MastodonTootRequest(secret: $0.0, status: $0.1, mediaIDs: $0.2))
        }
        // メディアアップロードアクション (Mastodon)
        tootUploadMediaAction = Action {
            return Session.shared.rx.response(MastodonMediaRequest(secret: $0.0, imageData: $0.1))
        }

        subscribeAction()
    }

    func getCurrentAccount() {
        postUser.accept(postUser.value)
    }

    func preparePost(image: UIImage?) {
        if let image = image, let data = image.pngData() {
            switch postContent.service {
            case .twitter:
                tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, data))
                Analytics.Tweet.postTweetTwitter(withHasImage: true, content: postContent)
            case .mastodon:
                tootUploadMediaAction.inputs.onNext((secretCredential, data))
                Analytics.Tweet.postTootMastodon(withHasImage: true, content: postContent)
            }
        } else {
            switch postContent.service {
            case .twitter:
                tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, nil))
                Analytics.Tweet.postTweetTwitter(withHasImage: false, content: postContent)
            case .mastodon:
                tootStatusAction.inputs.onNext((secretCredential, postMessage.value, nil))
                Analytics.Tweet.postTootMastodon(withHasImage: false, content: postContent)
            }
        }
    }
}

// MARK: - Private method

extension TweetViewModel {

    private func subscribeAction() {
        tweetStatusAction.elements
            .map { _ in }
            .subscribe(onNext: { [weak self] in
                self?._postResult.onNext(())
                self?._postResult.onCompleted()
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)

        tootStatusAction.elements
            .map { _ in }
            .subscribe(onNext: { [weak self] in
                self?._postResult.onNext(())
                self?._postResult.onCompleted()
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)

        tootUploadMediaAction.elements
            .subscribe(onNext: { [weak self] (response) in
                guard let wself = self else { return }
                wself.tootStatusAction.inputs.onNext((wself.secretCredential, wself.postMessage.value, [response.mediaID]))
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TweetViewModelType

extension TweetViewModel: TweetViewModelOutput {

    var postResult: Observable<Void> {
        return _postResult.observeOn(MainScheduler.instance).asObservable()
    }
}
