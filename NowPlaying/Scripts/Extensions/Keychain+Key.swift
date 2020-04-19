//
//  Keychain+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {

    enum Key: String {
        case authToken = "authToken"
        case authTokenSecret = "authTokenSecret"
        case mastodonAccessToken = "mastodon_access_token"
        case realmEncryptionKey = "realm_encryption_key"
    }

    static let nowPlaying = Keychain(service: .keychainServiceKey)

    subscript(key: Key) -> String? {
        set {
            self[key.rawValue] = newValue
        }
        get {
            return self[key.rawValue]
        }
    }

    subscript(string key: Key) -> String? {
        set {
            self[string: key.rawValue] = newValue
        }
        get {
            return self[string: key.rawValue]
        }
    }

    subscript(data key: Key) -> Data? {
        set {
            self[data: key.rawValue] = newValue
        }
        get {
            return self[data: key.rawValue]
        }
    }

    func remove(_ key: Key) throws {
        try remove(key.rawValue)
    }
}
