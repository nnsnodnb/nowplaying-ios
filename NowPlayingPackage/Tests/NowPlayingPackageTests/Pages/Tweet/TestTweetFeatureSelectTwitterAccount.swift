//
//  TestTweetFeatureSelectTwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTweetFeatureSelectTwitterAccount {
  @Test
  func testPresentedDelegateSelect() async throws {
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
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        postableTwitterAccount: twitterAccountA,
        selectTwitterAccount: .init(
          twitterAccounts: [twitterAccountA, twitterAccountB],
          selectedTwitterAccount: twitterAccountA,
        )
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.selectTwitterAccount(.presented(.delegate(.select(twitterAccountB))))) {
      $0.postableTwitterAccount = twitterAccountB
    }
    await store.receive(\.selectTwitterAccount.dismiss) {
      $0.selectTwitterAccount = nil
    }
  }
}
