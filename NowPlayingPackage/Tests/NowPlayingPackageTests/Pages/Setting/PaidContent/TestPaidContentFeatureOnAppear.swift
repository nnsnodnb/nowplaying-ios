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
struct TestPaidContentFeatureOnAppear {
  @Test
  func testIt() async throws {
    let postTicket = try Stub.make(PostTicket.self)

    await withDependencies {
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

      await store.send(.onAppear)
      await store.receive(\.internalAction.getNonConsumable)
      await store.receive(\.internalAction.setPostTickets) {
        $0.postTickets = [postTicket]
        $0.availablePostTicket = .initial
        $0.isLoadingPostTicket = false
      }
      await store.receive(\.internalAction.setNonConsumable, [])
    }
  }
}
