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
    case isMastodonWithImage = "is_mastodon_with_image"
    case isMastodonAutoToot = "is_mastodon_auto_toot"
    case isMastodonShowAutoTweetAlert = "is_mastodon_show_auto_tweet_alert"
}

enum KeychainKey: String {
    case authToken = "authToken"
    case authTokenSecret = "authTokenSecret"
    case mastodonClientID = "mastodon_client_id"
    case mastodonClientSecret = "mastodon_client_secret"
    case mastodonAccessToken = "mastodon_access_token"
}

enum EnvironmentKey: String {
    case twitterConsumerKey = "TWITTER_CONSUMER_KEY"
    case twitterConsumerSecret = "TWITTER_CONSUMER_SECRET"
}

let websiteUrl = "https://itunes.apple.com/jp/app/nowplaying-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88/id1289764391?mt=8"
