//
//  Keychain+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Foundation
import KeychainAccess

public extension Keychain {
  // MARK: - Keys
  enum Keys: String {
    case twitterAccounts = "twitter_accounts"
  }

  func object<D: Decodable>(forKey key: Keys) -> D? {
    guard let data = try? getData(key.rawValue) else { return nil }
    let decoder = JSONDecoder()
    let object = try? decoder.decode(D.self, from: data)
    return object
  }

  func set<E: Encodable>(_ object: E?, key: Keys) {
    guard let object else {
      try? remove(key.rawValue)
      return
    }
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(object)
      try set(data, key: key.rawValue)
    } catch {}
  }
}
