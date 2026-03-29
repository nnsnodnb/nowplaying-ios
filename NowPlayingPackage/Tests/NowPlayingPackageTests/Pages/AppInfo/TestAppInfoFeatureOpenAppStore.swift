//
//  TestAppInfoFeatureOpenAppStore.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestAppInfoFeatureOpenAppStore {
  @Test
  func testIt() async throws {
    await withDependencies {
      $0.openURL = OpenURLEffect { _ in
        #expect(true)
        return true
      }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(
          viewState: .updateAvailable,
        ),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.openAppStore)
    }
  }
}
