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
  enum Keys {
    case twitterAccounts
    case twitterOAuthToken(TwitterProfile.ID)
    case blueskyAccounts
    case blueskyAccountPassword(BlueskyAccount.DID)
    case purchasedNonConsumables
    case availablePostTicket

    // MARK: - Properties
    public var rawValue: String {
      switch self {
      case .twitterAccounts:
        "twitter_accounts"
      case let .twitterOAuthToken(id):
        "twitter_oauth_token_\(id.rawValue)"
      case .blueskyAccounts:
        "bluesky_accounts"
      case let .blueskyAccountPassword(did):
        "bluesky_account_password_\(did.rawValue)"
      case .purchasedNonConsumables:
        "purchased_non_nonsumables"
      case .availablePostTicket:
        "available_post_ticket"
      }
    }
  }

  func bool(forKey key: Keys) -> Bool {
    guard let data = try? getData(key.rawValue) else { return false }
    let decoder = JSONDecoder()
    let object = try? decoder.decode(Bool.self, from: data)
    return object ?? false
  }

  func object<D: Decodable>(forKey key: Keys) -> D? {
    guard let data = try? getData(key.rawValue) else { return nil }
    let decoder = JSONDecoder()
    let object = try? decoder.decode(D.self, from: data)
    return object
  }

  func set(_ boolValue: Bool, key: Keys) {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(boolValue)
      try set(data, key: key.rawValue)
    } catch {}
  }

  func set<E: Encodable>(_ object: E?, key: Keys) {
    guard let object else {
      try? remove(key)
      return
    }
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(object)
      try set(data, key: key.rawValue)
    } catch {}
  }

  func remove(_ key: Keys) throws {
    try remove(key.rawValue)
  }
}
