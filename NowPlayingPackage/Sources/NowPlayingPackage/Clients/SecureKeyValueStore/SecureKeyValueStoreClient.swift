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
  public var addTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var removeTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
}

// MARK: - DependencyKey
extension SecureKeyValueStoreClient: DependencyKey {
  public static let liveValue: Self = .init(
    twitterAccounts: {
      await Implementation.shared.getTwitterAccounts()
    },
    addTwitterAccount: { account in
      await Implementation.shared.addTwitterAccount(account)
    },
    removeTwitterAccount: { account in
      await Implementation.shared.removeTwitterAccount(account)
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

    func addTwitterAccount(_ account: TwitterAccount) {
      var accounts = getTwitterAccounts()
      guard !accounts.contains(account) else { return }
      if accounts.isEmpty {
        var account = account
        account.setDefault()
      }
      accounts.append(account)
      keychain.set(accounts, key: .twitterAccounts)
    }

    func removeTwitterAccount(_ account: TwitterAccount) {
      var accounts = getTwitterAccounts()
        .filter { $0 != account }
      if account.isDefault, var account = accounts.first {
        account.setDefault()
        accounts[0] = account
      }
      setTwitterAccounts(accounts)
    }

    private func setTwitterAccounts(_ accounts: [TwitterAccount]) {
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
