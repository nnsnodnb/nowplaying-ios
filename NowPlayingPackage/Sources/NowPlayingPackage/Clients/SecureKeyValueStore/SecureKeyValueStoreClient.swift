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
  // TwitterAccount
  public var getTwitterAccounts: @Sendable () async throws -> [TwitterAccount]
  public var addTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var updateDefaultTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var removeTwitterAccount: @Sendable (TwitterAccount) async throws -> Void
  public var setTwitterAccounts: @Sendable ([TwitterAccount]) async throws -> Void
  // TwitterOAuthToken
  public var getTwitterOAuthToken: @Sendable (TwitterAccount) async throws -> TwitterOAuthToken?
  public var setTwitterOAuthToken: @Sendable (TwitterAccount, TwitterOAuthToken) async throws -> Void
  // BlueskyAccount
  public var getBlueskyAccounts: @Sendable () async throws -> [BlueskyAccount]
  public var addBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var updateDefaultBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var removeBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var setBlueskyAccounts: @Sendable ([BlueskyAccount]) async throws -> Void
  // BlueskyAccount.Password
  public var getBlueskyAccountPassword: @Sendable (BlueskyAccount) async throws -> BlueskyAccount.Password?
  public var setBlueskyAccountPassword: @Sendable (BlueskyAccount, BlueskyAccount.Password) async throws -> Void
  // In-App Purchases
  public var getNonConsumables: @Sendable () async throws -> [NonConsumable]
  public var addNonConsumable: @Sendable (NonConsumable) async throws -> Void
  // AvailablePostTicket
  public var getAvailablePostTicket: @Sendable () async throws -> AvailablePostTicket
  public var setAvailablePostTicket: @Sendable (AvailablePostTicket) async throws -> Void
  // Misc
  public var resetAllData: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension SecureKeyValueStoreClient: DependencyKey {
  public static let liveValue: Self = .init(
    getTwitterAccounts: {
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
    getTwitterOAuthToken: { account in
      await Implementation.shared.getTwitterOAuthToken(for: account)
    },
    setTwitterOAuthToken: { account, oauthToken in
      await Implementation.shared.setTwitterOAuthToken(for: account, oauthToken: oauthToken)
    },
    getBlueskyAccounts: {
      await Implementation.shared.getBlueskyAccounts()
    },
    addBlueskyAccount: { account in
      await Implementation.shared.addBlueskyAccount(account: account)
    },
    updateDefaultBlueskyAccount: { account in
      await Implementation.shared.updateDefaultBlueskyAccount(account: account)
    },
    removeBlueskyAccount: { account in
      await Implementation.shared.removeBlueskyAccount(account: account)
    },
    setBlueskyAccounts: { accounts in
      await Implementation.shared.setBlueskyAccounts(accounts)
    },
    getBlueskyAccountPassword: { account in
      await Implementation.shared.getBlueskyAccountPassword(for: account)
    },
    setBlueskyAccountPassword: { account, password in
      await Implementation.shared.setBlueskyAccountPassword(for: account, password: password)
    },
    getNonConsumables: {
      await Implementation.shared.getNonConsumables()
    },
    addNonConsumable: { nonConsumable in
      await Implementation.shared.addNonConsumable(nonConsumable)
    },
    getAvailablePostTicket: {
      await Implementation.shared.getAvailablePostTicket()
    },
    setAvailablePostTicket: { availablePostTicket in
      await Implementation.shared.setAvailablePostTicket(availablePostTicket)
    },
    resetAllData: {
      try await Implementation.shared.resetAllData()
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
      try? keychain.remove(.twitterOAuthToken(account.profile.id))
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

    func getTwitterOAuthToken(for account: TwitterAccount) -> TwitterOAuthToken? {
      keychain.object(forKey: .twitterOAuthToken(account.profile.id))
    }

    func setTwitterOAuthToken(for account: TwitterAccount, oauthToken: TwitterOAuthToken) {
      keychain.set(oauthToken, key: .twitterOAuthToken(account.profile.id))
    }

    func getBlueskyAccounts() -> [BlueskyAccount] {
      keychain.object(forKey: .blueskyAccounts) ?? []
    }

    func addBlueskyAccount(account: BlueskyAccount) {
      var accounts = getBlueskyAccounts()
      let addingAccount: BlueskyAccount
      // 保存されているアカウントがなければデフォルトにする
      if accounts.isEmpty {
        var account = account
        account.setDefault()
        addingAccount = account
      } else {
        addingAccount = account
      }
      // すでに登録されている場合は追加しない
      guard !accounts.contains(where: { $0.id == addingAccount.id }) else {
        return
      }
      accounts.append(addingAccount)
      keychain.set(accounts, key: .blueskyAccounts)
    }

    func updateDefaultBlueskyAccount(account: BlueskyAccount) {
      let accounts = getBlueskyAccounts()
        .map { blueskyAccount in
          // 同じアカウントですでにデフォルトであればそのまま
          if blueskyAccount.id == account.id && !account.isDefault {
            return account
          }
          var blueskyAccount = blueskyAccount
          let isDefault = blueskyAccount.id == account.id
          blueskyAccount.setDefault(isDefault)
          return blueskyAccount
        }
      setBlueskyAccounts(accounts)
    }

    func removeBlueskyAccount(account: BlueskyAccount) {
      var accounts = getBlueskyAccounts()
        .filter { $0.handle != account.handle }
      try? keychain.remove(.blueskyAccountPassword(account.id))
      // 削除するアカウントがデフォルト設定されていて、残ったアカウントがあればデフォルトにする
      if account.isDefault, var account = accounts.first {
        account.setDefault()
        accounts[0] = account
      }
      setBlueskyAccounts(accounts)
    }

    func setBlueskyAccounts(_ accounts: [BlueskyAccount]) {
      keychain.set(accounts, key: .blueskyAccounts)
    }

    func getBlueskyAccountPassword(for account: BlueskyAccount) -> BlueskyAccount.Password? {
      keychain.object(forKey: .blueskyAccountPassword(account.id))
    }

    func setBlueskyAccountPassword(for account: BlueskyAccount, password: BlueskyAccount.Password) {
      keychain.set(password, key: .blueskyAccountPassword(account.id))
    }

    func getNonConsumables() -> [NonConsumable] {
      keychain.object(forKey: .purchasedNonConsumables) ?? []
    }

    func addNonConsumable(_ nonConsumable: NonConsumable) {
      let nonConsumables = getNonConsumables()
      guard !nonConsumables.contains(nonConsumable) else { return }
      keychain.set(nonConsumables + [nonConsumable], key: .purchasedNonConsumables)
    }

    func getAvailablePostTicket() -> AvailablePostTicket {
      keychain.object(forKey: .availablePostTicket) ?? .initial
    }

    func setAvailablePostTicket(_ availablePostTicket: AvailablePostTicket) {
      keychain.set(availablePostTicket, key: .availablePostTicket)
    }

    func resetAllData() throws {
      // TwitterAccount & TwitterOAuthToken
      let twitterAccounts = getTwitterAccounts()
      for twitterAccount in twitterAccounts {
        try? keychain.remove(.twitterOAuthToken(twitterAccount.profile.id))
      }
      try? keychain.remove(.twitterAccounts)
      // BlueskyAccount & BlueskyAccountPassword
      let blueskyAccounts = getBlueskyAccounts()
      for blueskyAccount in blueskyAccounts {
        try? keychain.remove(.blueskyAccountPassword(blueskyAccount.id))
      }
      try? keychain.remove(.blueskyAccounts)
      // NonConsumables
      try? keychain.remove(.purchasedNonConsumables)
      // AvailablePostTicket
      try? keychain.remove(.availablePostTicket)
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
