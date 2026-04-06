//
//  TestMastodonLoginFeatureChangedOAuthURL.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestMastodonLoginFeatureChangedOAuthURL {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.changedOAuthURL(URL(string: "https://testserver/oauth/authorize"))) {
      $0.oauthURL = URL(string: "https://testserver/oauth/authorize")
    }
  }

  @Test
  func testToNil() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(
        oauthURL: URL(string: "https://testserver/oauth/authorize"),
      ),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.changedOAuthURL(nil)) {
      $0.oauthURL = nil
    }
  }
}
