//
//  TestRootFeatureConsent.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/15.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureConsent {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: RootFeature.State(
        consent: .init(),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.consent(.delegate(.completedConsent))) {
      $0.consent = nil
      $0.signInAnonymously = .init()
    }
  }
}
