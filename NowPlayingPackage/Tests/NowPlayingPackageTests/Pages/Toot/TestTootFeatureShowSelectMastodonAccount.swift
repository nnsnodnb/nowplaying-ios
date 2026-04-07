//
//  TestTootFeatureShowSelectMastodonAccount.swift
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
struct TestTootFeatureShowSelectMastodonAccount {
  @Test
  func testOneAccount() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)

    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [mastodonAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.showSelectMastodonAccount)
  }

  @Test
  func testTwoAccount() async throws {
    let mastodonAccountA = try Stub.make(MastodonAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: true)
    }
    let mastodonAccountB = try Stub.make(MastodonAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: false)
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
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.showSelectMastodonAccount) {
      $0.selectMastodonAccount = .init(
        mastodonAccounts: [mastodonAccountA, mastodonAccountB],
        selectedMastodonAccount: mastodonAccountA,
      )
    }
  }
}
