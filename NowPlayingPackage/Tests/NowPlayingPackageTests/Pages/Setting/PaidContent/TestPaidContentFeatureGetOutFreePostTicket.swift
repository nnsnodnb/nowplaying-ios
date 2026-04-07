//
//  TestPaidContentFeatureGetOutFreePostTicket.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestPaidContentFeatureGetOutFreePostTicket {
  @Test
  func testWasNotGetOutFreePostTicket() async throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.totalFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 0)
      $0.set(\.totalPurchasedCount, value: 0)
    }
    let updatedAvailablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 10)
      $0.set(\.totalFreeCount, value: 10)
      $0.set(\.remainingPurchasedCount, value: 0)
      $0.set(\.totalPurchasedCount, value: 0)
    }

    await withDependencies {
      $0.secureKeyValueStore.getAvailablePostTicket = { availablePostTicket }
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
      $0.secureKeyValueStore.setGotOutFreePostTicket = { _ in }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(
          wasGettingOutFreePostTicket: false,
        ),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.getOutFreePostTicket)
      await store.receive(\.internalAction.updateAvailablePostTicket) {
        $0.availablePostTicket = updatedAvailablePostTicket
      }
      await store.receive(\.internalAction.earnGotOutPostFreeTicket) {
        $0.wasGettingOutFreePostTicket = true
        $0.alert = AlertState(
          title: {
            TextState(.freeTicketsAcquired)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          },
        )
      }
    }
  }

  @Test
  func testWasGetOutFreePostTicket() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(
        wasGettingOutFreePostTicket: true,
      ),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.getOutFreePostTicket)
  }
}
