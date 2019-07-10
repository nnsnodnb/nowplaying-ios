//
//  TwitterPostRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/09.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SwifteriOS

struct TwitterPostRequest {

    private let swifter: Swifter

    init(credential: SecretCredential) {
        swifter = Swifter(consumerKey: credential.consumerKey, consumerSecret: credential.consumerSecret,
                          oauthToken: credential.authToken, oauthTokenSecret: credential.authTokenSecret)
    }

    func postTweet(status: String, media: Data?=nil) -> Observable<JSON> {
        if let media = media {
            return _postTweet(status: status, media: media)
        } else {
            return _postTweet(status: status)
        }
    }
}

// MARK: - Private method

extension TwitterPostRequest {

    private func _postTweet(status: String) -> Observable<JSON> {
        return .create { [swifter] (observer) -> Disposable in
            swifter.postTweet(status: status, tweetMode: .extended, success: { (json) in
                observer.onNext(json)
                observer.onCompleted()
            }, failure: { (error) in
                observer.onError(error)
            })

            return Disposables.create()
        }
    }

    private func _postTweet(status: String, media: Data) -> Observable<JSON> {
        return .create { [swifter] (observer) -> Disposable in
            swifter.postTweet(status: status, media: media, tweetMode: .extended, success: { (json) in
                observer.onNext(json)
                observer.onCompleted()
            }, failure: { (error) in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
}
