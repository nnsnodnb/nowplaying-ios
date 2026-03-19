//
//  TestSocialServiceSettingFeaturePushSocialServiceAccountManage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSocialServiceSettingFeaturePushSocialServiceAccountManage {
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

    await store.send(.pushSocialServiceAccountManage)
    await store.receive(\.delegate.pushTwitterAccountManage)
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

    await store.send(.pushSocialServiceAccountManage)
    await store.receive(\.delegate.pushBlueskyAccountManage)
  }
}
