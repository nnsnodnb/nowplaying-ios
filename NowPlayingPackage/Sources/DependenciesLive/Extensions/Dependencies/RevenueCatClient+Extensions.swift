//
//  RevenueCatClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import CommonModule
import DependenciesInterfaces
import Foundation
import RevenueCat

public extension RevenueCatClient {
  static let revenueCat: Self = .init(
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
    purchasePostTicket: { postTicket in
      let offerings = try await Purchases.shared.offerings()
      guard let package = offerings.current?.availablePackages
        .first(where: { $0.identifier == postTicket.packageID.rawValue }) else {
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
