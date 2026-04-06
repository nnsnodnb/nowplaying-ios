//
//  TestMastodonLoginFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestMastodonLoginFeatureOnAppear {
  @Test(
    .dependencies {
      $0.mastodonOAuth.getCallbackURLScheme = { "test-scheme" }
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.onAppear) {
      $0.callbackURLScheme = "test-scheme"
    }
  }
}
