//
//  TestPostFeatureAddCapturedImage.swift
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
struct TestPostFeatureAddCapturedImage {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.addCapturedImage) {
      $0.attachmentImage = .init(systemSymbol: .photo)
      $0.isEditing = true
    }
  }
}
