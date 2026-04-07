//
//  TestTootFeatureAddArtwork.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTootFeatureAddArtwork {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.addArtwork) {
      $0.attachmentImage = .init(systemSymbol: .photoFill)
      $0.isEditing = true
    }
  }
}
