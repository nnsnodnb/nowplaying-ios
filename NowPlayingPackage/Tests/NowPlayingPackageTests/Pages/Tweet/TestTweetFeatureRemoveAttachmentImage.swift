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
@Suite(
  .dependency(\.date, .constant(.now)),
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTweetFeatureRemoveAttachmentImage {
  @Test(arguments: [1, 2])
  func testIt(totalPostTicketCount: Int) async throws {
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
        totalPostTicketCount: totalPostTicketCount,
        temporaryMedia: twitterMedia,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.removeAttachmentImage) {
      $0.attachmentImage = nil
      $0.usePostTicketCount = 1
      $0.temporaryMedia = nil
      $0.overUsablePostTicket = false
      $0.isEditing = true
    }
  }
}
