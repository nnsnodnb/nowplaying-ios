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

  @Test
  func testPathElementBlueskySettingDelegatePushBlueskyAccountManage() async throws {
    var path = StackState<SettingFeature.Path.State>()
    path[id: 0] = .blueskySetting(.init(socialService: .bluesky))

    let store = TestStore(
      initialState: SettingFeature.State(
        path: path,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.path(.element(id: 0, action: .blueskySetting(.delegate(.pushBlueskyAccountManage))))) {
      $0.path.append(.blueskyAccountManage(.init()))
    }
  }

  @Test
  func testPathElementPaidContentDelegateHideAds() async throws {
    var path = StackState<SettingFeature.Path.State>()
    path[id: 0] = .paidContent(.init())

    let store = TestStore(
      initialState: SettingFeature.State(
        path: path,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.path(.element(id: 0, action: .paidContent(.delegate(.hideAds)))))
    await store.receive(\.delegate.hideAds)
  }
}
