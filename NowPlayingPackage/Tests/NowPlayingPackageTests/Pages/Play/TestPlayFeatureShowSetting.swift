//
//  TestPlayFeatureShowSetting.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureShowSetting {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.showSetting) {
      $0.setting = .init()
    }
  }
}
