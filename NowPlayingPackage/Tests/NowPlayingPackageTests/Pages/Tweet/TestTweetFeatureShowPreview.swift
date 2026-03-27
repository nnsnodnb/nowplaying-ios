//
//  TestTweetFeatureShowPreview.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTweetFeatureShowPreview {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.showPreview(true)) {
      $0.isShowPreview = true
    }
  }
}
