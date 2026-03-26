//
//  TestAvailablePostTicketDecreasePurchasedCount
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

@testable import NowPlayingPackage
import StubKit
import Testing

struct TestAvailablePostTicketDecreasePurchasedCount {
  @Test
  func testFromZero() throws {
    var availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingPurchasedCount, value: 0)
      $0.set(\.totalPurchasedCount, value: 0)
    }

    availablePostTicket.decreasePurchasedCount(amount: 1)

    #expect(availablePostTicket.remainingPurchasedCount == 0)
    #expect(availablePostTicket.totalPurchasedCount == 0)
  }

  @Test
  func testRandomPurchasedCount() throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self)
    var updateAvailablePostTicket = availablePostTicket
    updateAvailablePostTicket.decreasePurchasedCount(amount: 1)

    #expect(updateAvailablePostTicket.remainingPurchasedCount == availablePostTicket.remainingPurchasedCount - 1)
    #expect(updateAvailablePostTicket.totalPurchasedCount == availablePostTicket.totalPurchasedCount)
  }
}
