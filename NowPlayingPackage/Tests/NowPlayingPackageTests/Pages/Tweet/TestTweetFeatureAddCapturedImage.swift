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
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTweetFeatureAddCapturedImage {
  @Test(arguments: [1, 2])
  func testIt(totalPostTicketCount: Int) async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photo),
        capturedImage: .init(systemSymbol: .photoFill),
        totalPostTicketCount: totalPostTicketCount,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.addCapturedImage) {
      $0.attachmentImage = .init(systemSymbol: .photoFill)
      $0.usePostTicketCount = 2
      if totalPostTicketCount == 1 {
        $0.overUsablePostTicket = true
      } else {
        $0.overUsablePostTicket = false
      }
      $0.isEditing = true
    }
  }
}
