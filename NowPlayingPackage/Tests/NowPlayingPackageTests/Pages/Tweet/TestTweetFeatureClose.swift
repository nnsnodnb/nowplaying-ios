//
//  TestTweetFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTweetFeatureClose {
  @Test
  func testIsEditing() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        isEditing: true,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.close) {
      $0.alert = AlertState(
        title: {
          TextState("ポストを削除します")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("キャンセル")
            },
          )
          ButtonState(
            role: .destructive,
            action: .delete,
            label: {
              TextState("削除")
            },
          )
        },
      )
    }
  }

  @Test
  func testIsNotEditing() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        isEditing: false,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.close)
  }
}
