//
//  Constants.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import KeychainAccess
import RealmSwift

let websiteURL = "https://itunes.apple.com/jp/app/nowplaying-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88/id1289764391?mt=8"

var realmConfiguration: Realm.Configuration {
    let schemaVersion: UInt64 = 1

    // すでに Keychain に保存されている場合
    if let encryptionKey = Keychain.nowPlaying[data: .realmEncryptionKey] {
        return .init(encryptionKey: encryptionKey, schemaVersion: schemaVersion)
    }

    // 暗号化キーが保存されていない場合は生成
    let data = NSMutableData(length: 64)!
    let result = SecRandomCopyBytes(kSecRandomDefault, 64, data.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
    assert(result == 0, "Failed to get random bytes")
    Keychain.nowPlaying[data: .realmEncryptionKey] = data as Data
    return .init(encryptionKey: data as Data, schemaVersion: schemaVersion)
}

extension String {

    static let keychainServiceKey = "moe.nnsnodnb.NowPlaying"
    static let defaultPostFormat = "__songtitle__ by __artist__ #NowPlaying"
}

extension URL {

    static let twitterCallbackURL = URL(string: "swifter-\(Environments.twitterConsumerKey)://success")!
}

extension Notification.Name {

    static let selectedMastodonInstance = Notification.Name("selected_mastodon_instance")
}
