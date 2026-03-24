//
//  RevenueCatClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/23.
//

import Dependencies
import DependenciesMacros
import Foundation
import RevenueCat

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
  public var buyMeACoffee: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension RevenueCatClient: DependencyKey {
  public static let liveValue: Self = .init(
    purchaseHideAds: {
      let offerings = try await Purchases.shared.offerings()
      guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == "$rc_hidead" }) else {
        throw Error.internalError
      }
      let result = try await Purchases.shared.purchase(product: package.storeProduct)
      if result.userCancelled {
        throw Error.userCancelled
      }
      if result.transaction?.transactionIdentifier != nil {
        return
      }
      throw Error.purchaseError
    },
    purchaseAutoTweet: {
      let offerings = try await Purchases.shared.offerings()
      guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == "$rc_auto_tweet" }) else {
        throw Error.internalError
      }
      let result = try await Purchases.shared.purchase(product: package.storeProduct)
      if result.userCancelled {
        throw Error.userCancelled
      }
      if result.transaction?.transactionIdentifier != nil {
        return
      }
      throw Error.purchaseError
    },
    restorePurchases: {
      let customerInfo = try await Purchases.shared.restorePurchases()
      let nonConsumables = customerInfo.nonSubscriptions
        .compactMap { NonConsumable(rawValue: $0.productIdentifier) }

      return Set(nonConsumables)
    },
    buyMeACoffee: {
      let offerings = try await Purchases.shared.offerings()
      guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == "$rc_buy_coffee" }) else {
        throw Error.internalError
      }
      let result = try await Purchases.shared.purchase(product: package.storeProduct)
      if result.userCancelled {
        throw Error.userCancelled
      }
      if result.transaction?.transactionIdentifier != nil {
        return
      }
      throw Error.purchaseError
    },
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
