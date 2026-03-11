//
//  TestPlayFeatureTogglePlayback.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureTogglePlayback {
  @Test(
    .dependencies {
      $0.mediaPlayer.playback = {}
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.togglePlayback)
  }
}
