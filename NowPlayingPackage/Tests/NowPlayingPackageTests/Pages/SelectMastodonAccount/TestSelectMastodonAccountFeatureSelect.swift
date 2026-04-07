//
//  TestSelectMastodonAccountFeatureSelect.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/21.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestSelectMastodonAccountFeatureSelect {
  @Test
  func testIt() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: SelectMastodonAccountFeature.State(
          mastodonAccounts: [mastodonAccount],
          selectedMastodonAccount: mastodonAccount,
        ),
        reducer: {
          SelectMastodonAccountFeature()
        },
      )

      await store.send(.select(mastodonAccount))
      await store.receive(\.delegate.select, mastodonAccount)
      #expect(calledDismiss)
    }
  }
}
