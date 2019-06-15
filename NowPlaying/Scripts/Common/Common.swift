//
//  Common.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/23.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case appOpenCount = "app_open_count"
    case isWithImage = "is_with_image"
    case isAutoTweetPurchase = "is_auto_tweet_purchase"
    case isAutoTweet = "is_auto_tweet"
    case tweetFormat = "tweet_format"
    case isShowAutoTweetAlert = "is_show_auto_tweet_alert"
    case mastodonClientID = "mastodon_client_id"
    case mastodonClientSecret = "mastodon_client_secret"
    case mastodonHostname = "mastodon_hostname"
    case mastodonAuthorizationCode = "authorization_code"
    case isMastodonLogin = "is_mastodon_login"
    case isMastodonWithImage = "is_mastodon_with_image"
    case isMastodonAutoToot = "is_mastodon_auto_toot"
    case tootFormat = "toot_format"
    case isMastodonShowAutoTweetAlert = "is_mastodon_show_auto_tweet_alert"
    case isPurchasedRemoveAdMob = "is_purchased_remove_admob"
    case isRemainTransaction = "IsRemainTransaction"
    case update210 = "update_2_1_0"
}

enum KeychainKey: String {
    case authToken = "authToken"
    case authTokenSecret = "authTokenSecret"
    case mastodonAccessToken = "mastodon_access_token"
}

enum EnvironmentKey: String {
    case twitterConsumerKey = "TWITTER_CONSUMER_KEY"
    case twitterConsumerSecret = "TWITTER_CONSUMER_SECRET"
    case mastodonConsumerKey = "MASTODON_CONSUMER_KEY"
    case mastodonConsumerSecret = "MASTODON_CONSUMER_SECRET"
    case firebaseAdmobAppId = "FIREBASE_ADMOB_APP_ID"
    case firebaseAdmobBannerId = "FIREBASE_ADMOB_BANNER_ID"
}

let keychainServiceKey = "moe.nnsnodnb.NowPlaying"

let websiteURL = "https://itunes.apple.com/jp/app/nowplaying-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88/id1289764391?mt=8"

let defaultPostFormat = "__songtitle__ by __artist__ #NowPlaying"

typealias Parameters = [String: Any]

extension NSNotification.Name {

    static let purchasedHideAdMobNotification = NSNotification.Name("purchasedHideAdMobNotification")
}
