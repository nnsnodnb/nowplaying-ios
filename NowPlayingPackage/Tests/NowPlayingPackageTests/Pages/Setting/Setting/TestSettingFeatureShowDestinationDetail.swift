//
//  TestSettingFeatureShowDestinationDetail.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/02.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeatureShowDestinationDetail {
  @Test
  func testTwitterSetting() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.twitterSetting)) {
      $0.destinationDetail = .twitterSetting
      $0.destination = .twitterSetting(.init(socialService: .twitter))
    }
  }

  @Test
  func testTwitterSettingExistPath() async throws {
    var path: StackState<SettingFeature.Path.State> = .init()
    path.append(.twitterAccountManage(.init()))

    let store = TestStore(
      initialState: SettingFeature.State(
        path: path,
        destinationDetail: .twitterSetting,
        destination: .twitterSetting(.init(socialService: .twitter)),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.twitterSetting)) {
      $0.path = .init()
    }
  }

  @Test
  func testBleuskySetting() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.blueskySetting)) {
      $0.destinationDetail = .blueskySetting
      $0.destination = .blueskySetting(.init(socialService: .bluesky))
    }
  }

  @Test
  func testMastodonSetting() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.mastodonSetting)) {
      $0.destinationDetail = .mastodonSetting
      $0.destination = .mastodonSetting(.init(socialService: .mastodon))
    }
  }

  @Test
  func testPaidContent() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.paidContent)) {
      $0.destinationDetail = .paidContent
      $0.destination = .paidContent(.init())
    }
  }

  @Test
  func testLicenseList() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showDestinationDetail(.licenseList)) {
      $0.destinationDetail = .licenseList
      $0.destination = .licenseList(.init())
    }
  }
}
