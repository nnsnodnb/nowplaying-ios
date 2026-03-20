//
//  TestBlueskyAccountManageFeatureFetchBlueskyAccounts.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureFetchBlueskyAccounts {
  @Test
  func testIt() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.blueskyAccounts = { [blueskyAccount] }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts) {
        $0.blueskyAccounts = [blueskyAccount]
      }
    }
  }
}
