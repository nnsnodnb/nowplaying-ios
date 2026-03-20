//
//  TestBlueskyLoginFeatureChangedPassword.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestBlueskyLoginFeatureChangedPassword {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.changedPassword("password")) {
      $0.password = "password"
    }
    await store.receive(\.internalAction.validate)
  }
}
