//
//  TestBlueskyAccountManageFeatureBlueskyLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureBlueskyLogin {
  @Test
  func testPresentedDelegateLoggedIn() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.getBlueskyAccounts = { [blueskyAccount] }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          blueskyLogin: .init(),
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.blueskyLogin(.presented(.delegate(.loggedIn(blueskyAccount))))) {
        $0.alert = AlertState(
          title: {
            TextState("ログインしました！")
          },
          message: {
            TextState("\(blueskyAccount.displayName ?? "") (@\(blueskyAccount.handle))")
          },
        )
      }
      await store.receive(\.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts) {
        $0.blueskyAccounts = [blueskyAccount]
      }
    }
  }
}
