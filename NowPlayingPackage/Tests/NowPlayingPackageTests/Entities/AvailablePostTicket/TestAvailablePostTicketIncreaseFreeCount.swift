//
//  TestAvailablePostTicketIncreaseFreeCount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

@testable import NowPlayingPackage
import StubKit
import Testing

struct TestAvailablePostTicketIncreaseFreeCount {
  @Test
  func testFromZero() throws {
    var availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.totalFreeCount, value: 0)
    }

    availablePostTicket.increaseFreeCount(amount: 1)

    #expect(availablePostTicket.remainingFreeCount == 1)
    #expect(availablePostTicket.totalFreeCount == 1)
  }

  @Test
  func testRandomFreeCount() throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self)
    var updateAvailablePostTicket = availablePostTicket
    updateAvailablePostTicket.increaseFreeCount(amount: 1)

    #expect(updateAvailablePostTicket.remainingFreeCount == availablePostTicket.remainingFreeCount + 1)
    #expect(updateAvailablePostTicket.totalFreeCount == availablePostTicket.totalFreeCount + 1)
  }
}
