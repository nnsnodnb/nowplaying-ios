//
//  SecureKeyValueStoreClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation

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
  public var removeTwitterOAuthToken: @Sendable (TwitterAccount) async throws -> Void
  // BlueskyAccount
  public var getBlueskyAccounts: @Sendable () async throws -> [BlueskyAccount]
  public var addBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var updateDefaultBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var removeBlueskyAccount: @Sendable (BlueskyAccount) async throws -> Void
  public var setBlueskyAccounts: @Sendable ([BlueskyAccount]) async throws -> Void
  // BlueskyAccount.Password
  public var getBlueskyAccountPassword: @Sendable (BlueskyAccount) async throws -> BlueskyAccount.Password?
  public var setBlueskyAccountPassword: @Sendable (BlueskyAccount, BlueskyAccount.Password) async throws -> Void
  // MastodonAccount
  public var getMastodonAccounts: @Sendable () async throws -> [MastodonAccount]
  public var addMastodonAccount: @Sendable (MastodonAccount) async throws -> Void
  public var updateDefaultMastodonAccount: @Sendable (MastodonAccount) async throws -> Void
  public var removeMastodonAccount: @Sendable (MastodonAccount) async throws -> Void
  public var setMastodonAccounts: @Sendable ([MastodonAccount]) async throws -> Void
  // MastodonOAuthToken
  public var getMastodonOAuthToken: @Sendable (MastodonAccount) async throws -> MastodonOAuthToken?
  public var setMastodonOAuthToken: @Sendable (MastodonAccount, MastodonOAuthToken) async throws -> Void
  // GiveOutFreePostTicket
  public var gaveOutFreePostTicket: @Sendable () async throws -> Bool
  public var setGiveOutFreePostTicket: @Sendable (Bool) async throws -> Void
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
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    addTwitterAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    updateDefaultTwitterAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    removeTwitterAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setTwitterAccounts: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getTwitterOAuthToken: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    removeTwitterOAuthToken: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getBlueskyAccounts: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    addBlueskyAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    updateDefaultBlueskyAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    removeBlueskyAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setBlueskyAccounts: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getBlueskyAccountPassword: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setBlueskyAccountPassword: { _, _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getMastodonAccounts: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    addMastodonAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    updateDefaultMastodonAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    removeMastodonAccount: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setMastodonAccounts: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getMastodonOAuthToken: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setMastodonOAuthToken: { _, _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    gaveOutFreePostTicket: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setGiveOutFreePostTicket: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getNonConsumables: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    addNonConsumable: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    getAvailablePostTicket: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    setAvailablePostTicket: { _ in
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
    resetAllData: {
      fatalError("Please set a value for `SecureKeyValueStoreClient.liveValue`.")
    },
  )
  public static let previewValue: Self = .init(
    getTwitterAccounts: {
      [TwitterAccount(profile: .nnsnodnb, isDefault: true)]
    },
    addTwitterAccount: { _ in },
    updateDefaultTwitterAccount: { _ in },
    removeTwitterAccount: { _ in },
    setTwitterAccounts: { _ in },
    getTwitterOAuthToken: { _ in nil },
    removeTwitterOAuthToken: { _ in },
    getBlueskyAccounts: {
      [BlueskyAccount(id: .init(""), handle: "nnsnodnb", displayName: "nnsnodnb", avatarImageURL: nil)]
    },
    addBlueskyAccount: { _ in },
    updateDefaultBlueskyAccount: { _ in },
    removeBlueskyAccount: { _ in },
    setBlueskyAccounts: { _ in },
    getBlueskyAccountPassword: { _ in nil },
    setBlueskyAccountPassword: { _, _ in },
    getMastodonAccounts: {
      [
        MastodonAccount(
          id: .init(""),
          domainURL: URL(string: "https://example.com")!,
          displayName: "nnsnodnb",
          username: "nnsnodnb",
          avatarURL: URL(string: "https://example.com")!,
        )
      ]
    },
    addMastodonAccount: { _ in },
    updateDefaultMastodonAccount: { _ in },
    removeMastodonAccount: { _ in },
    setMastodonAccounts: { _ in },
    getMastodonOAuthToken: { _ in nil },
    setMastodonOAuthToken: { _, _ in },
    gaveOutFreePostTicket: { false },
    setGiveOutFreePostTicket: { _ in },
    getNonConsumables: { [.hideAds] },
    addNonConsumable: { _ in },
    getAvailablePostTicket: { .initial },
    setAvailablePostTicket: { _ in },
    resetAllData: {},
  )
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
