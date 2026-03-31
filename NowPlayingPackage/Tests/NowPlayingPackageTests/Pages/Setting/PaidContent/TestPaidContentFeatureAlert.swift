//
//  TestPaidContentFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPaidContentFeatureAlert {
  @Test
  func testAlertPresentedWatchAds() async throws {
    let now = Date.now
    let availablePostTicket = try Stub.make(AvailablePostTicket.self)

    try await withDependencies {
      $0.date = .constant(now)
      $0.rewardedAd.load = { _ in }
      $0.rewardedAd.show = { _ in 1 }
      $0.secureKeyValueStore.getAvailablePostTicket = { availablePostTicket }
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(
          freeTicketAdUnitID: "ca-app-pub-3940256099942544/1712485313",
          alert: AlertState(
            title: {
              TextState("テスト")
            },
            actions: {
              ButtonState(
                action: .watchAds,
                label: {
                  TextState(.watch)
                },
              )
            },
          )
        ),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.alert(.presented(.watchAds))) {
        $0.isLoading = true
        $0.$earnFreeTicketDate.withLock { $0 = now }
        $0.alert = nil
      }
      await store.receive(\.internalAction.earnFreeTicket) {
        $0.isLoading = false
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
      let updateAvailablePostTicket = try Stub.make(AvailablePostTicket.self) {
        $0.set(\.remainingFreeCount, value: availablePostTicket.remainingFreeCount + 1)
        $0.set(\.totalFreeCount, value: availablePostTicket.totalFreeCount + 1)
      }
      await store.receive(\.internalAction.updateAvailablePostTicket, updateAvailablePostTicket) {
        $0.availablePostTicket = updateAvailablePostTicket
      }
    }
  }
}
