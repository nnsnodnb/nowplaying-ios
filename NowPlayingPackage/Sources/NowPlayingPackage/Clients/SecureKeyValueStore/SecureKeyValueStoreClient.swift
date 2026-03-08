//
//  SecureKeyValueStoreClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Dependencies
import DependenciesMacros
import Foundation
import KeychainAccess

@DependencyClient
public struct SecureKeyValueStoreClient: Sendable {
  public var twitterAccounts: @Sendable () async throws -> [TwitterAccount]
  public var setTwitterAccounts: @Sendable ([TwitterAccount]) async throws -> Void
  public var addTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
}

// MARK: - DependencyKey
extension SecureKeyValueStoreClient: DependencyKey {
  public static let liveValue: Self = .init(
    twitterAccounts: {
      await Implementation.shared.getTwitterAccounts()
    },
    setTwitterAccounts: { accounts in
      await Implementation.shared.setTwitterAccounts(accounts)
    },
    addTwitterAccount: { account in
      await Implementation.shared.addTwitterAccount(account)
    },
  )
}

// MARK: - Implementation
private extension SecureKeyValueStoreClient {
  final actor Implementation: GlobalActor {
    // MARK: - Properties
    static let shared = Implementation()

    private let keychain: Keychain = .init()

    func getTwitterAccounts() -> [TwitterAccount] {
      keychain.object(forKey: .twitterAccounts) ?? []
    }

    func setTwitterAccounts(_ accounts: [TwitterAccount]) {
      keychain.set(accounts, key: .twitterAccounts)
    }

    func addTwitterAccount(_ account: TwitterAccount) {
      var accounts = getTwitterAccounts()
      guard !accounts.contains(account) else { return }
      accounts.append(account)
      keychain.set(accounts, key: .twitterAccounts)
    }
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var secureKeyValueStore: SecureKeyValueStoreClient {
    get {
      self[SecureKeyValueStoreClient.self]
    }
    set {
      self[SecureKeyValueStoreClient.self] = newValue
    }
  }
}
