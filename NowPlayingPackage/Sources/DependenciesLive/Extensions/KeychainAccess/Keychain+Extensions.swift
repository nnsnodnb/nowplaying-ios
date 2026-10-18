//
//  Keychain+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import CommonModule
import Foundation
import KeychainAccess

public extension Keychain {
  // MARK: - Keys
  enum Keys {
    case twitterAccounts
    case twitterOAuthToken(TwitterProfile.ID)
    case blueskyAccounts
    case blueskyAccountPrivateKey(BlueskyAccount.DID)
    case blueskyAccountIdentity(BlueskyAccount.DID)
    case blueskyAccountLogin(BlueskyAccount.DID)
    case blueskyAccountPassword(BlueskyAccount.DID)
    case mastodonAccounts
    case mastodonOAuthToken(MastodonAccount.ID)
    case purchasedNonConsumables
    case availablePostTicket
    case gaveOutFreePostTicket

    // MARK: - Properties
    public var rawValue: String {
      switch self {
      case .twitterAccounts:
        "twitter_accounts"
      case let .twitterOAuthToken(id):
        "twitter_oauth_token_\(id.rawValue)"
      case .blueskyAccounts:
        "bluesky_accounts"
      case let .blueskyAccountPrivateKey(did):
        "bluesky_account_private_key_\(did.rawValue)"
      case let .blueskyAccountIdentity(did):
        "bluesky_account_identity_\(did.rawValue)"
      case let .blueskyAccountLogin(did):
        "bluesky_account_login_\(did.rawValue)"
      case let .blueskyAccountPassword(did):
        "bluesky_account_password_\(did.rawValue)"
      case .mastodonAccounts:
        "mastodon_accounts"
      case let .mastodonOAuthToken(id):
        "mastodon_oauth_token_\(id.rawValue)"
      case .purchasedNonConsumables:
        "purchased_non_nonsumables"
      case .availablePostTicket:
        "available_post_ticket"
      case .gaveOutFreePostTicket:
        "gave_out_free_post_ticket"
      }
    }
  }

  func bool(forKey key: Keys) -> Bool {
    guard let data = try? getData(key.rawValue) else { return false }
    let decoder = JSONDecoder()
    let object = try? decoder.decode(Bool.self, from: data)
    return object ?? false
  }

  func data(forKey key: Keys) -> Data? {
    try? getData(key.rawValue)
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

  func set(_ data: Data?, key: Keys) {
    guard let data else {
      try? remove(key)
      return
    }
    do {
      try set(data, key: key.rawValue)
    } catch {}
  }

  func remove(_ key: Keys) throws {
    try remove(key.rawValue)
  }
}
