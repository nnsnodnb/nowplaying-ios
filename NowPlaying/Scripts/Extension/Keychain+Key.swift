//
//  Keychain+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {

    static let nowPlaying = Keychain(service: keychainServiceKey)

    subscript(key: KeychainKey) -> String? {
        set {
            self[key.rawValue] = newValue
        }
        get {
            return self[key.rawValue]
        }
    }

    subscript(string key: KeychainKey) -> String? {
        set {
            self[string: key.rawValue] = newValue
        }
        get {
            return self[string: key.rawValue]
        }
    }

    subscript(data key: KeychainKey) -> Data? {
        set {
            self[data: key.rawValue] = newValue
        }
        get {
            return self[data: key.rawValue]
        }
    }

    func remove(_ key: KeychainKey) throws {
        try remove(key.rawValue)
    }
}
