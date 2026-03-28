//
//  TestRootFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestRootFeatureOnAppear {
  @Test
  func testIsLaunchAtFirst() async throws {
    await withDependencies {
      $0.secureKeyValueStore.resetAllData = { #expect(true) }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      store.state.$isLaunchAtFirst.withLock { $0 = true }

      await store.send(.onAppear) {
        $0.consent = .init()
      }
      await store.receive(\.internalAction.resetedSecureAllData) {
        $0.$isLaunchAtFirst.withLock { $0 = false }
      }
    }
  }

  @Test
  func testIsNotLaunchAtFirst() async throws {
    await withDependencies {
      $0.secureKeyValueStore.resetAllData = { Issue.record("DO not called resetAllData") }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      store.state.$isLaunchAtFirst.withLock { $0 = false }

      await store.send(.onAppear) {
        $0.consent = .init()
      }
    }
  }
}
