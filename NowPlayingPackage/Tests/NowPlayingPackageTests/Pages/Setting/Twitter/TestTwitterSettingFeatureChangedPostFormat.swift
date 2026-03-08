//
//  TestTwitterSettingFeatureChangedPostFormat.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeatureChangedPostFormat {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedPostFormat("__songtitle__ by __artist__ #NowPlaying")) {
      $0.$postFormat.withLock { $0 = "__songtitle__ by __artist__ #NowPlaying" }
    }
  }
}
