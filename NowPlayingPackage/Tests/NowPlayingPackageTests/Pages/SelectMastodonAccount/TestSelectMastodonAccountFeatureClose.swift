//
//  TestSelectMastodonAccountFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/21.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectMastodonAccountFeatureClose {
  @Test
  func testIt() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)

    let store = TestStore(
      initialState: SelectMastodonAccountFeature.State(
        mastodonAccounts: [mastodonAccount],
        selectedMastodonAccount: mastodonAccount,
      ),
      reducer: {
        SelectMastodonAccountFeature()
      },
    )

    await store.send(.close)
  }
}
