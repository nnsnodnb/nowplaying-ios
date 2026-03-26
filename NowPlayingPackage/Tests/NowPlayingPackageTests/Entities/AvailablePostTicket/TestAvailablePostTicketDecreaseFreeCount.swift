//
//  TestAvailablePostTicketDecreaseFreeCount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestAvailablePostTicketDecreaseFreeCount {
  @Test
  func testFromZero() throws {
    var availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.totalFreeCount, value: 0)
    }

    availablePostTicket.decreaseFreeCount(amount: 1)

    #expect(availablePostTicket.remainingFreeCount == 0)
    #expect(availablePostTicket.totalFreeCount == 0)
  }

  @Test
  func testRandomFreeCount() throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self)
    var updateAvailablePostTicket = availablePostTicket
    updateAvailablePostTicket.decreaseFreeCount(amount: 1)

    #expect(updateAvailablePostTicket.remainingFreeCount == availablePostTicket.remainingFreeCount - 1)
    #expect(updateAvailablePostTicket.totalFreeCount == availablePostTicket.totalFreeCount)
  }
}
