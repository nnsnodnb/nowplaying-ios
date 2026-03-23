//
//  TestBlueskyLoginFeatureChangedHandle.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestBlueskyLoginFeatureChangedHandle {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.changedHandle("example.bsky.social")) {
      $0.handle = "example.bsky.social"
    }
    await store.receive(\.internalAction.validate)
  }
}
