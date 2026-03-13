//
//  TestTweetFeaturePost.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTweetFeaturePost {
  @Test
  func testIsDisablePostButton() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        text: "",
        isDisablePostButton: true,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.post)
  }
}
