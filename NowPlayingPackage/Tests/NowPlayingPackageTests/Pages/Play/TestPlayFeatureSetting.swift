//
//  TestPlayFeatureSetting.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureSetting {
  @Test
  func testSettingPresentedDelegateHideAds() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        setting: .init(),
      ),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.setting(.presented(.delegate(.hideAds)))) {
      $0.isPurchasedHideAds = true
    }
  }
}
