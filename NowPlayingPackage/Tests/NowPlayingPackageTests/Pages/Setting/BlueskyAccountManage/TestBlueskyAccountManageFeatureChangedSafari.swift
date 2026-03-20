//
//  TestBlueskyAccountManageFeatureChangedSafari.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureChangedSafari {
  @Test
  func testToValue() async throws {
    let store = TestStore(
      initialState: BlueskyAccountManageFeature.State(),
      reducer: {
        BlueskyAccountManageFeature()
      },
    )

    await store.send(.changedSafari(.howToAddBlueskyAccount)) {
      $0.safari = .howToAddBlueskyAccount
    }
  }

  @Test
  func testToNil() async throws {
    let store = TestStore(
      initialState: BlueskyAccountManageFeature.State(
        safari: .howToAddBlueskyAccount,
      ),
      reducer: {
        BlueskyAccountManageFeature()
      },
    )

    await store.send(.changedSafari(nil)) {
      $0.safari = nil
    }
  }
}
