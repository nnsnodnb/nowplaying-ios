//
//  TestTwitterAccountManageFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureOnAppear {
  @Test(
    .dependencies {
      $0.twitterOAuth.getCallbackURLScheme = { "test-scheme" }
      $0.secureKeyValueStore.twitterAccounts = { [] }
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.onAppear) {
      $0.callbackURLScheme = "test-scheme"
    }
    await store.receive(\.fetchTwitterAccounts)
    await store.receive(\.internalAction.fetchedTwitterAccounts, [])
  }
}
