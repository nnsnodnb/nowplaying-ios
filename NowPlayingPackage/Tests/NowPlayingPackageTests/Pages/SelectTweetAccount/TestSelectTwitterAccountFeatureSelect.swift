//
//  TestSelectTwitterAccountFeatureSelect.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectTwitterAccountFeatureSelect {
  @Test
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: SelectTwitterAccountFeature.State(
        twitterAccounts: [twitterAccount],
        selectedTwitterAccount: twitterAccount,
      ),
      reducer: {
        SelectTwitterAccountFeature()
      },
    )

    await store.send(.select(twitterAccount))
    await store.receive(\.delegate.select, twitterAccount)
  }
}
