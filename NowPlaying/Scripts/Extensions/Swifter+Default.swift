//
//  Swifter+Default.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/25.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import SwifteriOS

extension Swifter {

    class func nowPlaying(oauthToken: String? = nil, oauthTokenSecret: String? = nil) -> Swifter {
        guard let key = oauthToken, let secret = oauthTokenSecret else {
            return .init(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)
        }
        return .init(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret,
                     oauthToken: key, oauthTokenSecret: secret)
    }
}
