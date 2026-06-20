//
//  SecureKeyValueStoreClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import CommonModule
import DependenciesInterfaces
import Foundation
import KeychainAccess

public extension SecureKeyValueStoreClient {
  static let keychainAccess: Self = .init(
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
    removeTwitterOAuthToken: { account in
      await Implementation.shared.removeTwitterOAuthToken(for: account)
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
    getMastodonAccounts: {
      await Implementation.shared.getMastodonAccounts()
    },
    addMastodonAccount: { account in
      await Implementation.shared.addMastodonAccount(account: account)
    },
    updateDefaultMastodonAccount: { account in
      await Implementation.shared.updateDefaultMastodonAccount(account: account)
    },
    removeMastodonAccount: { account in
      await Implementation.shared.removeMastodonAccount(account: account)
    },
    setMastodonAccounts: { accounts in
      await Implementation.shared.setMastodonAccounts(accounts)
    },
    getMastodonOAuthToken: { account in
      await Implementation.shared.getMastodonOAuthToken(for: account)
    },
    setMastodonOAuthToken: { account, oauthToken in
      await Implementation.shared.setMastodonOAuthToken(for: account, oauthToken: oauthToken)
    },
    gaveOutFreePostTicket: {
      await Implementation.shared.gaveOutFreePostTicket()
    },
    setGiveOutFreePostTicket: { value in
      await Implementation.shared.setGiveOutFreePostTicket(value)
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

    func removeTwitterOAuthToken(for account: TwitterAccount) {
      try? keychain.remove(.twitterOAuthToken(account.profile.id))
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

    func getMastodonAccounts() -> [MastodonAccount] {
      keychain.object(forKey: .mastodonAccounts) ?? []
    }

    func addMastodonAccount(account: MastodonAccount) {
      var accounts = getMastodonAccounts()
      let addingAccount: MastodonAccount
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
      keychain.set(accounts, key: .mastodonAccounts)
    }

    func updateDefaultMastodonAccount(account: MastodonAccount) {
      let accounts = getMastodonAccounts()
        .map { mastodonAccount in
          // 同じアカウントですでにデフォルトであればそのまま
          if mastodonAccount.id == account.id && !account.isDefault {
            return account
          }
          var mastodonAccount = mastodonAccount
          let isDefault = mastodonAccount.id == account.id
          mastodonAccount.setDefault(isDefault)
          return mastodonAccount
        }
      setMastodonAccounts(accounts)
    }

    func removeMastodonAccount(account: MastodonAccount) {
      var accounts = getMastodonAccounts()
        .filter { $0.id != account.id }
      try? keychain.remove(.mastodonOAuthToken(account.id))
      // 削除するアカウントがデフォルト設定されていて、残ったアカウントがあればデフォルトにする
      if account.isDefault, var account = accounts.first {
        account.setDefault()
        accounts[0] = account
      }
      setMastodonAccounts(accounts)
    }

    func setMastodonAccounts(_ accounts: [MastodonAccount]) {
      keychain.set(accounts, key: .mastodonAccounts)
    }

    func getMastodonOAuthToken(for account: MastodonAccount) -> MastodonOAuthToken? {
      keychain.object(forKey: .mastodonOAuthToken(account.id))
    }

    func setMastodonOAuthToken(for account: MastodonAccount, oauthToken: MastodonOAuthToken) {
      keychain.set(oauthToken, key: .mastodonOAuthToken(account.id))
    }

    func gaveOutFreePostTicket() -> Bool {
      keychain.bool(forKey: .gaveOutFreePostTicket)
    }

    func setGiveOutFreePostTicket(_ value: Bool) {
      keychain.set(value, key: .gaveOutFreePostTicket)
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
      // MastodonAccount & MastodonOAuthToken
      let mastodonAccounts = getMastodonAccounts()
      for mastodonAccount in mastodonAccounts {
        try? keychain.remove(.mastodonOAuthToken(mastodonAccount.id))
      }
      try? keychain.remove(.mastodonAccounts)
      // NonConsumables
      try? keychain.remove(.purchasedNonConsumables)
      // AvailablePostTicket
      try? keychain.remove(.availablePostTicket)
    }
  }
}
