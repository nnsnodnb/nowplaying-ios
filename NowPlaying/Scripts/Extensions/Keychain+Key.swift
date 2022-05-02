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
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }

    subscript(string key: Key) -> String? {
        get {
            return self[string: key.rawValue]
        }
        set {
            self[string: key.rawValue] = newValue
        }
    }

    subscript(data key: Key) -> Data? {
        get {
            return self[data: key.rawValue]
        }
        set {
            self[data: key.rawValue] = newValue
        }
    }

    func remove(_ key: Key) throws {
        try remove(key.rawValue)
    }
}
