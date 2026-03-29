//
//  TestAppInfoFeatureUpdateLater.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestAppInfoFeatureUpdateLater {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: AppInfoFeature.State(
        viewState: .updateAvailable,
      ),
      reducer: {
        AppInfoFeature()
      },
    )

    await store.send(.updateLater)
    await store.receive(\.delegate.completed)
  }
}
