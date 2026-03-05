//
//  TestPlayFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureOnAppear {
  @Test(
    .dependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.onAppear) {
      $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    }
  }
}
