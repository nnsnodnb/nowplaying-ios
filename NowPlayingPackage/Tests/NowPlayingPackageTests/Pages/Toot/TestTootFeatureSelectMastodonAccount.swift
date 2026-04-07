//
//  TestTootFeatureSelectMastodonAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTootFeatureSelectMastodonAccount {
  @Test
  func testPresentedDelegateSelectSameAccount() async throws {
    let mastodonAccountA = try Stub.make(MastodonAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: false)
    }
    let mastodonAccountB = try Stub.make(MastodonAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: true)
    }

    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [mastodonAccountA, mastodonAccountB],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableMastodonAccount: mastodonAccountA,
        selectMastodonAccount: .init(
          mastodonAccounts: [mastodonAccountA, mastodonAccountB],
          selectedMastodonAccount: mastodonAccountA,
        ),
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.selectMastodonAccount(.presented(.delegate(.select(mastodonAccountA)))))
    await store.receive(\.selectMastodonAccount.dismiss) {
      $0.selectMastodonAccount = nil
    }
  }
}
