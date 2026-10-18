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
      $0.isDisabledLoginButton = false
    }
  }

  @Test(arguments: [" ", "\n"])
  func testToIsDisabledLoginButton(handle: String) async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        handle: handle,
        isDisabledLoginButton: false,
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.changedHandle(handle)) {
      $0.handle = handle
      $0.isDisabledLoginButton = true
    }
  }
}
