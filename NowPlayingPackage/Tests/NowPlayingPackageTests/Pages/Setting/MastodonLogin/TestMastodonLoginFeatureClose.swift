//
//  TestMastodonLoginFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestMastodonLoginFeatureClose {
  @Test
  func testIt() async throws {
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.close)
      #expect(calledDismiss)
    }
  }
}
