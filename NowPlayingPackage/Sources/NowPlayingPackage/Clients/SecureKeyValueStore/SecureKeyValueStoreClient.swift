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
  public var updateDefaultTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var removeTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var setTwitterAccounts: @Sendable ([TwitterAccount]) async throws -> Void
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
    updateDefaultTwitterAccount: { account in
      await Implementation.shared.updateDefaultTwitterAccount(account)
    },
    removeTwitterAccount: { account in
      await Implementation.shared.removeTwitterAccount(account)
    },
    setTwitterAccounts: { accounts in
      await Implementation.shared.setTwitterAccounts(accounts)
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
      let addingAccount: TwitterAccount
      // 保存されているアカウントがなければデフォルトにする
      if accounts.isEmpty {
        var account = account
        account.setDefault()
        addingAccount = account
      } else {
        addingAccount = account
      }
      // すでに登録されている場合は追加しない
      guard !accounts.contains(where: { $0.profile.id == addingAccount.profile.id }) else {
        return
      }
      accounts.append(addingAccount)
      keychain.set(accounts, key: .twitterAccounts)
    }

    func updateDefaultTwitterAccount(_ account: TwitterAccount) {
      let accounts = getTwitterAccounts()
        .map { twitterAccount in
          // 同じアカウントですでにデフォルトであればそのまま
          if twitterAccount.profile.id == account.profile.id && !account.isDefault {
            return account
          }
          var twitterAccount = twitterAccount
          let isDefault = twitterAccount.profile.id == account.profile.id
          twitterAccount.setDefault(isDefault)
          return twitterAccount
        }
      setTwitterAccounts(accounts)
    }

    func removeTwitterAccount(_ account: TwitterAccount) {
      var accounts = getTwitterAccounts()
        .filter { $0.profile.id != account.profile.id }
      // 削除するアカウントがデフォルト設定されていて、残ったアカウントがあればデフォルトにする
      if account.isDefault, var account = accounts.first {
        account.setDefault()
        accounts[0] = account
      }
      setTwitterAccounts(accounts)
    }

    func setTwitterAccounts(_ accounts: [TwitterAccount]) {
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
