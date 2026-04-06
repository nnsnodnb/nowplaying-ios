//
//  TestSettingFeaturePushMastodonSetting.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeaturePushMastodonSetting {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.pushMastodonSetting) {
      $0.path[id: 0] = .mastodonSetting(.init(socialService: .mastodon))
    }
  }
}
