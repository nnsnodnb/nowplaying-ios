//
//  TestSettingFeaturePath.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeaturePath {
  @Test
  func testPathElementTwitterSettingDelegatePushTwitterAccountManage() async throws {
    var path = StackState<SettingFeature.Path.State>()
    path[id: 0] = .twitterSetting(.init(socialService: .twitter))

    let store = TestStore(
      initialState: SettingFeature.State(
        path: path,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.path(.element(id: 0, action: .twitterSetting(.delegate(.pushTwitterAccountManage))))) {
      $0.path.append(.twitterAccountManage(.init()))
    }
  }
}
