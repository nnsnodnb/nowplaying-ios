//
//  TestRootFeatureAppInfo.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureAppInfo {
  @Test
  func testAppInfoDelegateCompleted() async throws {
    let store = TestStore(
      initialState: RootFeature.State(
        appInfo: .init()
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.appInfo(.delegate(.completed))) {
      $0.appInfo = nil
      $0.consent = .init()
    }
  }
}
