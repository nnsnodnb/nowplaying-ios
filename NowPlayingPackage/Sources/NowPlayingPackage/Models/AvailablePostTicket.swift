//
//  AvailablePostTicket.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct AvailablePostTicket: Codable, Equatable, Sendable {
  // MARK: - Properties
  public static let initial: Self = .init()

  // 残りの無料チケット
  @Init(.public, default: 0)
  public private(set) var remainingFreeCount: Int
  // 今まで獲得した合計の無料チケット
  @Init(.public, default: 0)
  public private(set) var totalFreeCount: Int
  // 残りの有料チケット
  @Init(.public, default: 0)
  public private(set) var remainingPurchasedCount: Int
  // 今まで購入した合計の有料チケット
  @Init(.public, default: 0)
  public private(set) var totalPurchasedCount: Int

  // 使用できる無料チケットを増やす
  public mutating func increaseFreeCount(amount: Int) {
    remainingFreeCount += amount
    totalFreeCount += amount
  }

  // 使用できる無料チケットを減らす
  public mutating func decreaseFreeCount(amount: Int) {
    remainingFreeCount = max(remainingFreeCount - amount, 0)
  }

  // 使用できる有料チケットを増やす
  public mutating func increasePurchasedCount(amount: Int) {
    remainingPurchasedCount += amount
    totalPurchasedCount += amount
  }

  // 使用できる有料チケットを減らす
  public mutating func decreasePurchasedCount(amount: Int) {
    remainingPurchasedCount = max(remainingPurchasedCount - amount, 0)
  }
}
