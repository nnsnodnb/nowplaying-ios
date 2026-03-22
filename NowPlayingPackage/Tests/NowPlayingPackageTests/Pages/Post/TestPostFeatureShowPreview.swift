//
//  TestPostFeatureShowPreview.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPostFeatureShowPreview {
  @Test(arguments: [true, false])
  func testIt(isShow: Bool) async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        isShowPreview: !isShow,
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.showPreview(isShow)) {
      $0.isShowPreview = isShow
    }
  }
}
