//
//  TestRootFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureOnAppear {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: RootFeature.State(),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.onAppear) {
      $0.consent = .init()
    }
  }
}
