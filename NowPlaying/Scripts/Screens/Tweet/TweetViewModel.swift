//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

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
//            MastodonRequest.Toot(status: postMessage.value).send { [weak self] (result) in
//                switch result {
//                case .success:
//                    self?._success.accept(())
//                case .failure(let error):
//                    self?._failure.accept(error)
//                }
//            }
            Analytics.Tweet.postTootMastodon(withHasImage: false, content: postContent)
        }
    }

    func preparePost(withImage image: UIImage) {
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
            MastodonClient.shared.toot(text: postMessage.value, image: image) { [weak self] (error) in
                if let error = error {
                    self?._failure.accept(error)
                } else {
                    self?._success.accept(())
                }
            }
            Analytics.Tweet.postTootMastodon(withHasImage: true, content: postContent)
        }
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
}
