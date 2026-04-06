//
//  TestMastodonAccountManageFeatureFetchMastodonAccounts.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonAccountManageFeatureFetchMastodonAccounts {
  @Test
  func testIt() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.getMastodonAccounts = { [mastodonAccount] }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.fetchMastodonAccounts)
      await store.receive(\.internalAction.fetchedMastodonAccounts, [mastodonAccount]) {
        $0.mastodonAccounts = [mastodonAccount]
      }
    }
  }
}
