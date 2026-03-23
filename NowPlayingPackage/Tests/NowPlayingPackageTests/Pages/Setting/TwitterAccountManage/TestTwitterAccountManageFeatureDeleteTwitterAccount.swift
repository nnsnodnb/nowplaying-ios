//
//  TestTwitterAccountManageFeatureDeleteTwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTwitterAccountManageFeatureDeleteTwitterAccount {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.getTwitterAccounts = { [] }
      $0.secureKeyValueStore.removeTwitterAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          twitterAccounts: [twitterAccount],
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.deleteTwitterAccount(.init(arrayLiteral: 0)))
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts, []) {
        $0.twitterAccounts = []
      }
    }
  }
}
