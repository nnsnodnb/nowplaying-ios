//
//  TestSocialServiceSettingFeatureChangedTootVisibility.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestSocialServiceSettingFeatureChangedTootVisibility {
  @Test(arguments: [SocialService.twitter, SocialService.bluesky])
  func testNonSupportSocialService(_ socialService: SocialService) async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: socialService,
        mastodonTootVisibility: .`public`,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedTootVisibility(.`private`))
  }

  @Test
  func testMastodonChange() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .mastodon,
        mastodonTootVisibility: .`public`
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedTootVisibility(.unlisted)) {
      $0.$mastodonTootVisibility.withLock { $0 = .unlisted }
    }
  }

  @Test
  func testMastodonNoChange() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .mastodon,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedTootVisibility(.`public`))
  }
}
