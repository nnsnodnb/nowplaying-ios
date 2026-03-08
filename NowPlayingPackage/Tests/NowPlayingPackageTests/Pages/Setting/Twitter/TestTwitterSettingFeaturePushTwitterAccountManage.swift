//
//  TestTwitterSettingFeaturePushTwitterAccountManage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeaturePushTwitterAccountManage {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.pushTwitterAccountManage)
    await store.receive(\.delegate.pushTwitterAccountManage)
  }
}
