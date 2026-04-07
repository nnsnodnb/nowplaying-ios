//
//  TestTootFeatureShowPreview.swift
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
struct TestTootFeatureShowPreview {
  @Test(arguments: [true, false])
  func testIt(isShow: Bool) async throws {
    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        isShowPreview: !isShow,
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.showPreview(isShow)) {
      $0.isShowPreview = isShow
    }
  }
}
