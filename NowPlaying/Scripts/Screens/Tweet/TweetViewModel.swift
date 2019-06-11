//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import FirebaseAnalytics
import Foundation
import RxCocoa
import RxSwift
import SVProgressHUD

struct TweetViewModelInput {

    let postContent: PostContent
    let textViewText: Observable<String>
}

// MARK: - TweetViewModelOutput

protocol TweetViewModelOutput {

    var isPostable: Observable<Bool> { get }
    var successRequest: Observable<Void> { get }
    var failureRequest: Observable<Error> { get }
}

// MARK: - TweetViewModelType

protocol TweetViewModelType {

    var outputs: TweetViewModelOutput { get }

    init(inputs: TweetViewModelInput)
    func preparePost()
    func preparePost(withImage image: UIImage)
}

final class TweetViewModel: TweetViewModelType {

    var outputs: TweetViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let postContent: PostContent
    private let postMessage: BehaviorRelay<String>
    private let _success = PublishRelay<Void>()
    private let _failure = PublishRelay<Error>()

    init(inputs: TweetViewModelInput) {
        postContent = inputs.postContent
        postMessage = BehaviorRelay<String>(value: inputs.postContent.postMessage)

        inputs.textViewText
            .bind(to: postMessage)
            .disposed(by: disposeBag)
    }

    func preparePost() {
        UIApplication.shared.windows.forEach { $0.endEditing(true) }
        SVProgressHUD.show()
        switch postContent.service {
        case .twitter:
            TwitterClient.shared.client?.sendTweet(withText: postMessage.value) { [weak self] (_, error) in
                if let error = error {
                    self?._failure.accept(error)
                } else {
                    self?._success.accept(())
                }
            }
            Analytics.Tweet.postTweetTwitter(withHasImage: false, content: postContent)
        case .mastodon:
            Session.shared.rx.response(MastodonTootRequest(status: postMessage.value))
                .subscribe(onSuccess: { [weak self] (_) in
                    self?._success.accept(())
                }, onError: { [weak self] (error) in
                    print(error)
                    self?._failure.accept(error)
                })
                .disposed(by: disposeBag)
            Analytics.Tweet.postTootMastodon(withHasImage: false, content: postContent)
        }
    }

    func preparePost(withImage image: UIImage) {
        UIApplication.shared.windows.forEach { $0.endEditing(true) }
        SVProgressHUD.show()
        switch postContent.service {
        case .twitter:
            TwitterClient.shared.client?.sendTweet(withText: postMessage.value, image: image) { [weak self] (_, error) in
                if let error = error {
                    self?._failure.accept(error)
                } else {
                    self?._success.accept(())
                }
            }
            Analytics.Tweet.postTweetTwitter(withHasImage: true, content: postContent)
        case .mastodon:
            guard let imageData = image.pngData() else {
                _failure.accept(NSError(domain: "画像が見つかりませんでした", code: 400, userInfo: nil))
                return
            }
            Session.shared.rx.response(MastodonMediaRequest(imageData: imageData))
                .subscribe(onSuccess: { [weak self] (response) in
                    self?.tootWithMediaID(response.mediaID)
                }, onError: { [weak self] (error) in
                    self?._failure.accept(error)
                })
                .disposed(by: disposeBag)
            Analytics.Tweet.postTootMastodon(withHasImage: true, content: postContent)
        }
    }
}

// MARK: - Private method

extension TweetViewModel {

    private func tootWithMediaID(_ mediaID: String) {
        Session.shared.rx.response(MastodonTootRequest(status: postMessage.value, mediaIDs: [mediaID]))
            .subscribe(onSuccess: { [weak self] (_) in
                self?._success.accept(())
            }, onError: { [weak self] (error) in
                self?._failure.accept(error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TweetViewModelType

extension TweetViewModel: TweetViewModelOutput {

    var successRequest: Observable<Void> {
        return _success.observeOn(MainScheduler.instance).asObservable()
    }

    var failureRequest: Observable<Error> {
        return _failure.observeOn(MainScheduler.instance).asObservable()
    }

    var isPostable: Observable<Bool> {
        return postMessage
            .map { !$0.isEmpty }
            .observeOn(MainScheduler.instance)
            .asObservable()
    }
}
