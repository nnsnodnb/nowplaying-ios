//
//  TestSelectBlueskyAccountFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/21.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectBlueskyAccountFeatureClose {
  @Test
  func testIt() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    let store = TestStore(
      initialState: SelectBlueskyAccountFeature.State(
        blueskyAccounts: [blueskyAccount],
        selectedBlueskyAccount: blueskyAccount,
      ),
      reducer: {
        SelectBlueskyAccountFeature()
      },
    )

    await store.send(.close)
  }
}
