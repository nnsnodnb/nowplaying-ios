//
//  RevenueCatClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/23.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct RevenueCatClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case userCancelled
    case purchaseError
    case internalError
  }

  public var purchaseHideAds: @Sendable () async throws -> Void
  public var purchaseAutoTweet: @Sendable () async throws -> Void
  public var restorePurchases: @Sendable () async throws -> Set<NonConsumable>
  public var purchasePostTicket: @Sendable (PostTicket) async throws -> Void
  public var buyMeACoffee: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension RevenueCatClient: DependencyKey {
  public static let liveValue: Self = .init(
    purchaseHideAds: {
      fatalError("Please set a value for `RevenueCatClient.liveValue`.")
    },
    purchaseAutoTweet: {
      fatalError("Please set a value for `RevenueCatClient.liveValue`.")
    },
    restorePurchases: {
      fatalError("Please set a value for `RevenueCatClient.liveValue`.")
    },
    purchasePostTicket: { _ in
      fatalError("Please set a value for `RevenueCatClient.liveValue`.")
    },
    buyMeACoffee: {
      fatalError("Please set a value for `RevenueCatClient.liveValue`.")
    },
  )
  public static let previewValue: Self = .init(
    purchaseHideAds: {},
    purchaseAutoTweet: {},
    restorePurchases: { .init(arrayLiteral: .hideAds) },
    purchasePostTicket: { _ in },
    buyMeACoffee: {},
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var revenueCat: RevenueCatClient {
    get {
      self[RevenueCatClient.self]
    }
    set {
      self[RevenueCatClient.self] = newValue
    }
  }
}
