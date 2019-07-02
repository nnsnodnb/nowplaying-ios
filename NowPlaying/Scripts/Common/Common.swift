//
//  Common.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/23.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation
import KeychainAccess
import RealmSwift

enum UserDefaultsKey: String {
    case appOpenCount = "app_open_count"
    case isWithImage = "is_with_image"
    case isAutoTweetPurchase = "is_auto_tweet_purchase"
    case isAutoTweet = "is_auto_tweet"
    case tweetFormat = "tweet_format"
    case tweetWithImageType = "tweet_with_image_type"
    case isShowAutoTweetAlert = "is_show_auto_tweet_alert"
    case mastodonClientID = "mastodon_client_id"
    case mastodonClientSecret = "mastodon_client_secret"
    case mastodonHostname = "mastodon_hostname"
    case mastodonAuthorizationCode = "authorization_code"
    case isMastodonLogin = "is_mastodon_login"
    case isMastodonWithImage = "is_mastodon_with_image"
    case isMastodonAutoToot = "is_mastodon_auto_toot"
    case tootFormat = "toot_format"
    case tootWithImageType = "toot_with_image_type"
    case isMastodonShowAutoTweetAlert = "is_mastodon_show_auto_tweet_alert"
    case isPurchasedRemoveAdMob = "is_purchased_remove_admob"
    case isRemainTransaction = "IsRemainTransaction"
    case update210 = "update_2_1_0"
}

enum KeychainKey: String {
    case authToken = "authToken"
    case authTokenSecret = "authTokenSecret"
    case mastodonAccessToken = "mastodon_access_token"
    case realmEncryptionKey = "realm_encryption_key"
}

enum EnvironmentKey: String {
    case twitterConsumerKey = "TWITTER_CONSUMER_KEY"
    case twitterConsumerSecret = "TWITTER_CONSUMER_SECRET"
    case mastodonConsumerKey = "MASTODON_CONSUMER_KEY"
    case mastodonConsumerSecret = "MASTODON_CONSUMER_SECRET"
    case firebaseAdmobAppId = "FIREBASE_ADMOB_APP_ID"
    case firebaseAdmobBannerId = "FIREBASE_ADMOB_BANNER_ID"
    case mastodonInstancesApiToken = "MASTODON_INSTANCES_API_TOKEN"
}

let keychainServiceKey = "moe.nnsnodnb.NowPlaying"

let websiteURL = "https://itunes.apple.com/jp/app/nowplaying-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88/id1289764391?mt=8"

let defaultPostFormat = "__songtitle__ by __artist__ #NowPlaying"

typealias Parameters = [String: Any]

extension NSNotification.Name {

    static let purchasedHideAdMobNotification = NSNotification.Name("purchasedHideAdMobNotification")
}

var realmConfiguration: Realm.Configuration {
    let keychain = Keychain(service: keychainServiceKey)
    let schemaVersion: UInt64 = 1

    // すでに Keychain に保存されている場合
    if let encryptionKey = keychain[data: KeychainKey.realmEncryptionKey.rawValue] {
        return .init(encryptionKey: encryptionKey, schemaVersion: schemaVersion)
    }

    // 暗号化キーが保存されていない場合は生成
    let data = NSMutableData(length: 64)!
    let result = SecRandomCopyBytes(kSecRandomDefault, 64, data.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
    assert(result == 0, "Failed to get random bytes")
    keychain[data: KeychainKey.realmEncryptionKey.rawValue] = data as Data
    return .init(encryptionKey: data as Data, schemaVersion: schemaVersion)
}
