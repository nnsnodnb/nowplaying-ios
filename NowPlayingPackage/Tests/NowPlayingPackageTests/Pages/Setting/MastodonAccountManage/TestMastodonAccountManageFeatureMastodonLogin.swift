//
//  TestMastodonAccountManageFeatureMastodonLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonAccountManageFeatureMastodonLogin {
  @Test
  func testIt() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self) {
      $0.set(\.displayName, value: "表示名")
      $0.set(\.username, value: "example")
    }

    await withDependencies {
      $0.secureKeyValueStore.getMastodonAccounts = { [mastodonAccount] }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(
          mastodonLogin: .init(),
        ),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.mastodonLogin(.presented(.delegate(.loggedIn(mastodonAccount))))) {
        $0.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("表示名 (@example)")
          },
        )
      }
      await store.receive(\.fetchMastodonAccounts)
      await store.receive(\.internalAction.fetchedMastodonAccounts, [mastodonAccount]) {
        $0.mastodonAccounts = [mastodonAccount]
      }
    }
  }
}
