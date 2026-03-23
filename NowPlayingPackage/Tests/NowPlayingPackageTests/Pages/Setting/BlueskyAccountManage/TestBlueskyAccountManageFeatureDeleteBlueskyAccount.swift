//
//  TestBlueskyAccountManageFeatureDeleteBlueskyAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureDeleteBlueskyAccount {
  @Test
  func testIt() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.removeBlueskyAccount = { _ in }
      $0.secureKeyValueStore.getBlueskyAccounts = { [] }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          blueskyAccounts: [blueskyAccount],
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.deleteBlueskyAccount([0]))
      await store.receive(\.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts) {
        $0.blueskyAccounts = []
      }
    }
  }
}
