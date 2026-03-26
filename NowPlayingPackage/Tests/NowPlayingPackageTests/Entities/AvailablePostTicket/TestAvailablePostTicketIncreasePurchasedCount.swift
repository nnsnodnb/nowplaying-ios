//
//  TestAvailablePostTicketIncreasePurchasedCount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

@testable import NowPlayingPackage
import StubKit
import Testing

struct TestAvailablePostTicketIncreasePurchasedCount {
  @Test
  func testFromZero() throws {
    var availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingPurchasedCount, value: 0)
      $0.set(\.totalPurchasedCount, value: 0)
    }

    availablePostTicket.increasePurchasedCount(amount: 1)

    #expect(availablePostTicket.remainingPurchasedCount == 1)
    #expect(availablePostTicket.totalPurchasedCount == 1)
  }

  @Test
  func testRandomPurchasedCount() throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self)
    var updateAvailablePostTicket = availablePostTicket
    updateAvailablePostTicket.increasePurchasedCount(amount: 1)

    #expect(updateAvailablePostTicket.remainingPurchasedCount == availablePostTicket.remainingPurchasedCount + 1)
    #expect(updateAvailablePostTicket.totalPurchasedCount == availablePostTicket.totalPurchasedCount + 1)
  }
}
