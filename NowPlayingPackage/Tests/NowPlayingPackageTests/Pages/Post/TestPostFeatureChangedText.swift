//
//  TestPostFeatureChangedText.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPostFeatureChangedText {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.changedText("テスト")) {
      $0.text = "テスト"
      $0.isEditing = true
      $0.isDisablePostButton = false
    }
  }

  @Test(arguments: ["", "\n", " "])
  func testWhitespacesAndNewLines(text: String) async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        text: "テスト",
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.changedText(text)) {
      $0.text = text
      $0.isEditing = true
      $0.isDisablePostButton = true
    }
  }
}
