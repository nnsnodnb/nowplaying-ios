//
//  TestSelectTweetAccountFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectTweetAccountFeatureClose {
  @Test
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: SelectTweetAccountFeature.State(
        twitterAccounts: [twitterAccount],
        selectedTwitterAccount: twitterAccount,
      ),
      reducer: {
        SelectTweetAccountFeature()
      },
    )

    await store.send(.close)
  }
}
