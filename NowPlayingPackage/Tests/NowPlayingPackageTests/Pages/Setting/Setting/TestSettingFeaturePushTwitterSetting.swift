//
//  TestSettingFeaturePushTwitterSetting.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeaturePushTwitterSetting {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.pushTwitterSetting) {
      $0.path[id: 0] = .twitterSetting(.init(socialService: .twitter))
    }
  }
}
