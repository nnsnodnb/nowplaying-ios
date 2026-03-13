//
//  TestTweetFeatureAddArtwork.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTweetFeatureAddArtwork {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.addArtwork) {
      $0.attachmentImage = .init(systemSymbol: .photoFill)
      $0.isEditing = true
    }
  }
}
