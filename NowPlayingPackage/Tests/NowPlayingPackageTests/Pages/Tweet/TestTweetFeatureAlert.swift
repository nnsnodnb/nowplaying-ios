//
//  TestTweetFeatureAlert.swift
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
struct TestTweetFeatureAlert {
  @Test
  func testPresentedDelete() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        alert: AlertState(
          title: {
            TextState("テスト")
          },
          actions: {
            ButtonState(
              action: .delete,
              label: {
                TextState("削除")
              },
            )
          },
        )
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.alert(.presented(.delete))) {
      $0.alert = nil
    }
  }
}
