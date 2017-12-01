//
//  Common.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/23.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case isWithImage = "is_with_image"
    case isAutoTweet = "is_auto_tweet"
    case isShowAutoTweetAlert = "is_show_auto_tweet_alert"
    case mastodonHostname = "mastodon_hostname"
    case isMastodonLogin = "is_mastodon_login"
}

enum KeychainKey: String {
    case authToken = "authToken"
    case authTokenSecret = "authTokenSecret"
    case mastodonClientID = "mastodon_client_id"
    case mastodonClientSecret = "mastodon_client_secret"
    case mastodonAccessToken = "mastodon_access_token"
}
