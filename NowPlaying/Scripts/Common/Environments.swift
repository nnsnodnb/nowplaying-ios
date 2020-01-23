//
//  Environments.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

import Foundation

enum EnvironmentKey: String {
    case twitterConsumerKey = "TWITTER_CONSUMER_KEY"
    case twitterConsumerSecret = "TWITTER_CONSUMER_SECRET"
    case firebaseAdmobAppID = "FIREBASE_ADMOB_APP_ID"
    case firebaseAdmobBannerID = "FIREBASE_ADMOB_BANNER_ID"
    case mastodonInstancesApiToken = "MASTODON_INSTANCES_API_TOKEN"
}

struct Environments {

    static var twitterConsumerKey: String {
        return Bundle.environments[key: .twitterConsumerKey] as! String
    }

    static var twitterConsumerSecret: String {
        return Bundle.environments[key: .twitterConsumerSecret] as! String
    }

    static var firebaseAdmobAppID: String {
        return Bundle.environments[key: .firebaseAdmobAppID] as! String
    }

    static var firebaseAdmobBannerID: String {
        return Bundle.environments[key: .firebaseAdmobBannerID] as! String
    }

    static var mastodonInstancesApiToken: String {
        return Bundle.environments[key: .mastodonInstancesApiToken] as! String
    }
}

extension Bundle {

    static let environments: [String: Any] = {
        return Bundle.main.object(forInfoDictionaryKey: "LSEnvironment") as! [String: Any]
    }()
}

extension Dictionary where Key == String, Value == Any {

    subscript(key key: EnvironmentKey) -> Any? {
        return self[key.rawValue]
    }
}
