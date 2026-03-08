//
//  TestTwitterSettingFeatureResetFormat.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeatureResetFormat {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(
        postFormat: "test",
      ),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.resetFormat) {
      $0.$postFormat.withLock { $0 = "__songtitle__ / __artist__ #NowPlaying" }
    }
    await store.receive(\.changedPostFormat, "__songtitle__ / __artist__ #NowPlaying")
  }
}
