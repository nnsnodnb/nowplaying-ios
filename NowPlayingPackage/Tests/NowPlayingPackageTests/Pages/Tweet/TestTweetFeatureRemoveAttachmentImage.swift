//
//  TestTweetFeatureRemoveAttachmentImage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTweetFeatureRemoveAttachmentImage {
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
        attachmentImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.removeAttachmentImage) {
      $0.attachmentImage = nil
    }
  }
}
