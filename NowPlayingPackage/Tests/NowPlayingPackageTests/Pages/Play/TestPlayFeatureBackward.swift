//
//  TestPlayFeatureBackward.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureBackward {
  @Test(
    .dependencies {
      $0.mediaPlayer.backward = {}
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
      ),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.backward)
  }
}
