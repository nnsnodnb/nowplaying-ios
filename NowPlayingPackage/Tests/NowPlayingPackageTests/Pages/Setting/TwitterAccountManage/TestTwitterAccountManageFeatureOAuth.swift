//
//  TestTwitterAccountManageFeatureOAuth.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureOAuth {
  @Test
  func testIt() async throws {
    let oauthURL = URL(string: "https://testserver/oauth")!

    await withDependencies {
      $0.twitterOAuth.getAuthenticateURL = { oauthURL }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.oauth) {
        $0.oauthURL = oauthURL
      }
    }
  }
}
