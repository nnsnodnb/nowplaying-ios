//
//  TestPaidContentFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPaidContentFeatureOnAppear {
  @Test
  func testIt() async throws {
    await withDependencies {
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
      await store.receive(\.internalAction.setNonConsumable, [])
    }
  }
}
