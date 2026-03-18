//
//  TestTweetFeatureRemoveAttachmentImage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTweetFeatureRemoveAttachmentImage {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testIt() async throws {
    let twitterMedia = try Stub.make(TwitterMedia.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        attachmentImage: .init(systemSymbol: .photo),
        temporaryMedia: twitterMedia,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.removeAttachmentImage) {
      $0.attachmentImage = nil
      $0.temporaryMedia = nil
    }
  }
}
