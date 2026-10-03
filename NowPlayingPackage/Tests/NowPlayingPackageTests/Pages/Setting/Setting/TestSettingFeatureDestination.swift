//
//  TestSettingFeatureDestination.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeatureDestination {
  @Test
  func testPresentedTwitterSettingDelegatePushTwitterAccountManage() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        destinationDetail: .twitterSetting,
        destination: .twitterSetting(.init(socialService: .twitter)),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.destination(.presented(.twitterSetting(.delegate(.pushTwitterAccountManage))))) {
      $0.path[id: 0] = .twitterAccountManage(.init())
    }
  }

  @Test
  func testPresentedBlueskySettingDelegatePushBlueskyAccountManage() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        destinationDetail: .blueskySetting,
        destination: .blueskySetting(.init(socialService: .bluesky)),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.destination(.presented(.blueskySetting(.delegate(.pushBlueskyAccountManage))))) {
      $0.path[id: 0] = .blueskyAccountManage(.init())
    }
  }

  @Test
  func testPresentedMastodonSettingDelegatePushMastodonAccountManage() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        destinationDetail: .mastodonSetting,
        destination: .mastodonSetting(.init(socialService: .mastodon)),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.destination(.presented(.mastodonSetting(.delegate(.pushMastodonAccountManage))))) {
      $0.path[id: 0] = .mastodonAccountManage(.init())
    }
  }

  @Test
  func testPresentedPaidContentDelegateHideAds() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        destinationDetail: .paidContent,
        destination: .paidContent(.init()),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.destination(.presented(.paidContent(.delegate(.hideAds)))))
    await store.receive(\.delegate.hideAds)
  }

  @Test
  func testPresentedLicenseListDelegatePushLicenseDetail() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        destinationDetail: .licenseList,
        destination: .licenseList(.init()),
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.destination(.presented(.licenseList(.delegate(.pushLicenseDetail(LicensesPlugin.licenses[0])))))) {
      $0.path[id: 0] = .licenseDetail(.init(license: LicensesPlugin.licenses[0]))
    }
  }
}
