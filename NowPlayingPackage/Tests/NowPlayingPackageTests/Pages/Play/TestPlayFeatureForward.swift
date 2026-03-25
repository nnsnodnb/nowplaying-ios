//
//  TestPlayFeatureForward.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureForward {
  @Test(
    .dependencies {
      $0.mediaPlayer.forward = {}
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

    await store.send(.forward)
  }
}
