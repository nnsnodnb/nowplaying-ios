//
//  TestPaidContentFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPaidContentFeatureOnAppear {
  @Test
  func testIt() async throws {
    let postTicket = try Stub.make(PostTicket.self)

    await withDependencies {
      $0.adUnit.getFreePostTicketRewardAdUnitID = { "ca-app-pub-3940256099942544/1712485313" }
      $0.apiClient.getPostTickets = { [postTicket] }
      $0.secureKeyValueStore.getAvailablePostTicket = { .initial }
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.onAppear) {
        $0.initialized = true
        $0.freeTicketAdUnitID = "ca-app-pub-3940256099942544/1712485313"
      }
      await store.receive(\.internalAction.getNonConsumable)
      await store.receive(\.internalAction.setPostTickets) {
        $0.postTickets = [postTicket]
        $0.availablePostTicket = .initial
        $0.isLoadingPostTicket = false
      }
      await store.receive(\.internalAction.setNonConsumable, [])
    }
  }

  @Test
  func testDidInitialize() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(
        initialized: true,
      ),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.onAppear)
  }
}
