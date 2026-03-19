//
//  TestSocialServiceSettingFeatureChangedPostFormat.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSocialServiceSettingFeatureChangedPostFormat {
  @Test
  func testTwitter() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedPostFormat("__songtitle__ by __artist__ #NowPlaying")) {
      $0.$twitterPostFormat.withLock { $0 = "__songtitle__ by __artist__ #NowPlaying" }
    }
  }

  @Test
  func testBluesky() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedPostFormat("__songtitle__ by __artist__ #NowPlaying")) {
      $0.$blueskyPostFormat.withLock { $0 = "__songtitle__ by __artist__ #NowPlaying" }
    }
  }
}
