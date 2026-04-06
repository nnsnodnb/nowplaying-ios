//
//  TestMastodonAccountManageFeatureDeleteMastodonAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonAccountManageFeatureDeleteMastodonAccount {
  @Test
  func testIt() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: true)
    }

    await withDependencies {
      $0.secureKeyValueStore.getMastodonAccounts = { [] }
      $0.secureKeyValueStore.removeMastodonAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(
          mastodonAccounts: [mastodonAccount]
        ),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.deleteMastodonAccount(.init(arrayLiteral: 0)))
      await store.receive(\.fetchMastodonAccounts)
      await store.receive(\.internalAction.fetchedMastodonAccounts, []) {
        $0.mastodonAccounts = []
      }
    }
  }
}
