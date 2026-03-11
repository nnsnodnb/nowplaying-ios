//
//  TestTwitterAccountManageFeatureChangedOAuthURL.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureChangedOAuthURL {
  @Test
  func testToValue() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.changedOAuthURL(URL(string: "https://testserver/oauth")!)) {
      $0.oauthURL = URL(string: "https://testserver/oauth")!
    }
  }

  @Test
  func testToNil() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        oauthURL: URL(string: "https://testserver/oauth")!,
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.changedOAuthURL(nil)) {
      $0.oauthURL = nil
    }
  }
}
