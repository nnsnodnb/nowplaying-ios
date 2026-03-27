//
//  TestConsentFeatureCompleted.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestConsentFeatureCompleted {
  @Test
  func testCompleted() async throws {
    let store = TestStore(
      initialState: ConsentFeature.State(),
      reducer: {
        ConsentFeature()
      },
    )

    await store.send(.completed)
    await store.receive(\.delegate.completedConsent)
  }
}
