//
//  TestMastodonAccountManageFeatureAddAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestMastodonAccountManageFeatureAddAccount {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: MastodonAccountManageFeature.State(),
      reducer: {
        MastodonAccountManageFeature()
      },
    )

    await store.send(.addAccount) {
      $0.mastodonLogin = .init()
    }
  }
}
