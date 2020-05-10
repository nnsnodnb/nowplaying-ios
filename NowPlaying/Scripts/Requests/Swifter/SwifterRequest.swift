//
//  SwifterRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/10.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import SwifteriOS
import UIKit

struct SwifterRequest {

    private let swifter: Swifter

    init(secretCredential: SecretCredential) {
        swifter = .init(consumerKey: secretCredential.consumerKey, consumerSecret: secretCredential.consumerSecret,
                        oauthToken: secretCredential.authToken, oauthTokenSecret: secretCredential.authTokenSecret)
    }

    func postTweet(status: String, media: Data? = nil, success: Swifter.SuccessHandler?, failure: Swifter.FailureHandler?) {
        if let media = media, let data = compressionMedia(media) {
            swifter.postTweet(status: status, media: data, tweetMode: .extended, success: success, failure: failure)
        } else {
            swifter.postTweet(status: status, tweetMode: .extended, success: success, failure: failure)
        }
    }

    // MARK: - Private method

    private func compressionMedia(_ media: Data) -> Data? {
        if Double(media.count) < 5e6 { return media } // 5MB以上であれば圧縮する
        return UIImage(data: media)?.jpegData(compressionQuality: 0.3)
    }
}
