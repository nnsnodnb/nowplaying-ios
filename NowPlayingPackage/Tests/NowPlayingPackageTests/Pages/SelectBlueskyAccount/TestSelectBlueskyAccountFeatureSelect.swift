//
//  TestSelectBlueskyAccountFeatureSelect.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/21.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectBlueskyAccountFeatureSelect {
  @Test
  func testIt() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: SelectBlueskyAccountFeature.State(
          blueskyAccounts: [blueskyAccount],
          selectedBlueskyAccount: blueskyAccount,
        ),
        reducer: {
          SelectBlueskyAccountFeature()
        },
      )

      await store.send(.select(blueskyAccount))
      await store.receive(\.delegate.select, blueskyAccount)
      #expect(calledDismiss)
    }
  }
}
