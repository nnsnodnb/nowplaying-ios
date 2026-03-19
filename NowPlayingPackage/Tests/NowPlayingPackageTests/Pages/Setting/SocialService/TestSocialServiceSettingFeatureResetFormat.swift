//
//  TestSocialServiceSettingFeatureResetFormat.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSocialServiceSettingFeatureResetFormat {
  @Test
  func testTwitter() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
        twitterPostFormat: "test",
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.resetFormat) {
      $0.$twitterPostFormat.withLock { $0 = "__songtitle__ / __artist__ #NowPlaying" }
    }
    await store.receive(\.changedPostFormat, "__songtitle__ / __artist__ #NowPlaying")
  }

  @Test
  func testBluesky() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
        blueskyPostFormat: "test",
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.resetFormat) {
      $0.$blueskyPostFormat.withLock { $0 = "__songtitle__ / __artist__ #NowPlaying" }
    }
    await store.receive(\.changedPostFormat, "__songtitle__ / __artist__ #NowPlaying")
  }
}
