//
//  TestTwitterAccountManageFeatureFetchTwitterAccounts.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTwitterAccountManageFeatureFetchTwitterAccounts {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }
}
