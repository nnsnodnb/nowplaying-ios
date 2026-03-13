//
//  TestTweetFeatureChangedText.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTweetFeatureChangedText {
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
        text: "曲名 / アーティスト #NowPlaying",
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.changedText("テスト")) {
      $0.text = "テスト"
      $0.isEditing = true
    }
  }

  @Test(arguments: ["", " ", "\n"])
  func testToOnlyWhitespace(newText: String) async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        text: "曲名 / アーティスト #NowPlaying",
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.changedText(newText)) {
      $0.text = newText
      $0.isEditing = true
      $0.isDisablePostButton = true
    }
  }
}
