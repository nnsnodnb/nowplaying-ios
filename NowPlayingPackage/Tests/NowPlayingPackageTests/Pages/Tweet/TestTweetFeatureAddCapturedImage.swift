//
//  TestTweetFeatureAddCapturedImage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTweetFeatureAddCapturedImage {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photo),
        capturedImage: .init(systemSymbol: .photoFill),
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.addCapturedImage) {
      $0.attachmentImage = .init(systemSymbol: .photoFill)
      $0.usePostTicketCount = 2
      $0.isEditing = true
    }
  }
}
