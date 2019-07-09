//
//  UserDefaults+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/04/14.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

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
    case singleAccountToMultiAccounts = "single_account_to_multi_accounts"
}

extension UserDefaults {

    class func set(_ url: URL?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(url, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ string: String?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(string, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ integer: Int, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(integer, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ float: Float, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(float, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ double: Double, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(double, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ bool: Bool, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(bool, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func set(_ obj: Any?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(obj, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func removeObject(forKey key: UserDefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func bool(forKey key: UserDefaultsKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    class func integer(forKey key: UserDefaultsKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }

    class func string(forKey key: UserDefaultsKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    class func object(forKey key: UserDefaultsKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}

extension Reactive where Base: UserDefaults {

    func change<Element>(_ type: Element.Type, _ key: UserDefaultsKey,
                         options: KeyValueObservingOptions = [.new, .initial],
                         retainSelf: Bool = true) -> Observable<Element?> {
        return base.rx.observe(type.self, key.rawValue)
    }
}
