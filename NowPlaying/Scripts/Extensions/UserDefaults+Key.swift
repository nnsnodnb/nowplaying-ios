//
//  UserDefaults+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

protocol UserDefaultsNumber {}

extension Int: UserDefaultsNumber {}
extension Float: UserDefaultsNumber {}
extension Double: UserDefaultsNumber {}
extension Bool: UserDefaultsNumber {}

extension UserDefaults {

    enum Key: String {
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
        case singleAccountToMultiAccounts = "single_account_to_multi_accounts"
    }

    func set(_ string: String?, forKey key: Key) {
        set(string, forKey: key.rawValue)
        synchronize()
    }

    func set<T: UserDefaultsNumber>(_ value: T, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    func set(_ url: URL?, forKey key: Key) {
        set(url, forKey: key.rawValue)
        synchronize()
    }

    func set(_ object: Any?, forKey key: Key) {
        set(object, forKey: key.rawValue)
        synchronize()
    }

    func removeObject(forKey key: Key) {
        removeObject(forKey: key.rawValue)
        synchronize()
    }

    func bool(forKey key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }

    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }

    func data(forKey key: Key) -> Data? {
        return data(forKey: key.rawValue)
    }

    func url(forKey key: Key) -> URL? {
        return url(forKey: key.rawValue)
    }

    func object(forKey key: Key) -> Any? {
        return object(forKey: key.rawValue)
    }
}
