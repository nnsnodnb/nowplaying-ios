//
//  TestTwitterAccountManageFeatureSavedTwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTwitterAccountManageFeatureSavedTwitterAccount {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testIt() async throws {
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

      await store.send(.savedTwitterAccount) {
        $0.isLoading = false
      }
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.fetchedTwitterAccounts) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }
}
