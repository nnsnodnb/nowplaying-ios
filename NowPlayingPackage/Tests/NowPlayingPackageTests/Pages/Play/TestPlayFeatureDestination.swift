//
//  TestPlayFeatureDestination.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureDestination {
  @Test
  func testDestinationPresentedSettingDelegateHideAds() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        destination: .setting(.init()),
      ),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.destination(.presented(.setting(.delegate(.hideAds))))) {
      $0.isPurchasedHideAds = true
    }
  }
}
