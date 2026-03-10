//
//  TestTwitterAccountManageFeatureInternalAction.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTwitterAccountManageFeatureInternalAction {
  @Test
  func testRequestGetUserMe() async throws {
    // TODO: 実装
  }

  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testSavedTwitterAccount() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          isLoading: true,
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.internalAction(.savedTwitterAccount)) {
        $0.isLoading = false
      }
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }
}
