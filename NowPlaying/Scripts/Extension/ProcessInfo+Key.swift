//
//  ProcessInfo+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/04/14.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

typealias Environment = [String: String]

enum EnvironmentKey: String {
    case twitterConsumerKey = "TWITTER_CONSUMER_KEY"
    case twitterConsumerSecret = "TWITTER_CONSUMER_SECRET"
    case mastodonConsumerKey = "MASTODON_CONSUMER_KEY"
    case mastodonConsumerSecret = "MASTODON_CONSUMER_SECRET"
    case firebaseAdmobAppId = "FIREBASE_ADMOB_APP_ID"
    case firebaseAdmobBannerId = "FIREBASE_ADMOB_BANNER_ID"
    case mastodonInstancesApiToken = "MASTODON_INSTANCES_API_TOKEN"
}

extension ProcessInfo {

    func get(forKey key: EnvironmentKey) -> String {
        return ProcessInfo.processInfo.environment[key.rawValue]!
    }
}
