//
//  TestRootFeatureMigrateV320.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestRootFeatureMigrateV320 {
  @Test
  func testDelegateCompleted() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          migrateV320: .init()
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.migrateV320(.delegate(.completed)))
      await store.receive(\.internalAction.showPlay, false) {
        $0.migrateV320 = nil
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }
}
