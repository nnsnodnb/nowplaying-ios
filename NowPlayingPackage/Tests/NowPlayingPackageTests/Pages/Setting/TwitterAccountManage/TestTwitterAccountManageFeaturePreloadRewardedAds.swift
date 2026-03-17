//
//  TestTwitterAccountManageFeaturePreloadRewardedAds.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeaturePreloadRewardedAds {
  @Test(
    .dependencies {
      $0.adUnit.addTwitterAccountRewardAdUnitID = { "ca-app-pub-3940256099942544/1712485313" }
      $0.rewardedAd.load = { _ in }
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.preloadRewardedAds)
  }
}
