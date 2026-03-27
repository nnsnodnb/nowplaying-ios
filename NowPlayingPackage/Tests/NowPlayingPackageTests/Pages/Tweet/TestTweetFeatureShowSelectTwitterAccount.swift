//
//  TestTweetFeatureShowSelectTwitterAccount.swift
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
struct TestTweetFeatureShowSelectTwitterAccount {
  @Test
  func testTwitterAccountIsOne() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableTwitterAccount: twitterAccount,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.showSelectTwitterAccount)
  }

  @Test
  func testTwitterAccountIsTwo() async throws {
    let twitterProfileA = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_a"))
    }
    let twitterAccountA = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileA)
      $0.set(\.isDefault, value: true)
    }
    let twitterProfileB = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_b"))
    }
    let twitterAccountB = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileB)
    }

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccountA, twitterAccountB],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableTwitterAccount: twitterAccountA,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.showSelectTwitterAccount) {
      $0.selectTwitterAccount = .init(
        twitterAccounts: [twitterAccountA, twitterAccountB],
        selectedTwitterAccount: twitterAccountA,
      )
    }
  }
}
