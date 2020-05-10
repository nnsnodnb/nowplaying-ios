//
//  SwifterRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/10.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import SwifteriOS

struct SwifterRequest {

    private let swifter: Swifter

    init(secretCredential: SecretCredential) {
        swifter = .init(consumerKey: secretCredential.consumerKey, consumerSecret: secretCredential.consumerSecret,
                        oauthToken: secretCredential.authToken, oauthTokenSecret: secretCredential.authTokenSecret)
    }

    func postTweet(status: String, media: Data? = nil, success: Swifter.SuccessHandler?, failure: Swifter.FailureHandler?) {
        if let media = media {
            swifter.postTweet(status: status, media: media, tweetMode: .extended, success: success, failure: failure)
        } else {
            swifter.postTweet(status: status, tweetMode: .extended, success: success, failure: failure)
        }
    }

    // MARK: - Private method

    private func _postTweet(status: String, success: Swifter.SuccessHandler?, failure: Swifter.FailureHandler?) {
        swifter.postTweet(status: status, tweetMode: .extended, success: success, failure: failure)
    }
}
