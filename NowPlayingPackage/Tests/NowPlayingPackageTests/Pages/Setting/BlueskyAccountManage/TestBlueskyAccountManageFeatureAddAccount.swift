//
//  TestBlueskyAccountManageFeatureAddAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureAddAccount {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: BlueskyAccountManageFeature.State(),
      reducer: {
        BlueskyAccountManageFeature()
      },
    )

    await store.send(.addAccount) {
      $0.blueskyLogin = .init()
    }
  }
}
