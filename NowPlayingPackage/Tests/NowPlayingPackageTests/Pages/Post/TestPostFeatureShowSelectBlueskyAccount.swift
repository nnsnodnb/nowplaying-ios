//
//  TestPostFeatureShowSelectBlueskyAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPostFeatureShowSelectBlueskyAccount {
  @Test
  func testOneAccount() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [blueskyAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.showSelectBlueskyAccount)
  }

  @Test
  func testTwoAccount() async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: true)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: false)
    }

    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [blueskyAccountA, blueskyAccountB],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableBlueskyAccount: blueskyAccountA,
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.showSelectBlueskyAccount) {
      $0.selectBlueskyAccount = .init(
        blueskyAccounts: [blueskyAccountA, blueskyAccountB],
        selectedBlueskyAccount: blueskyAccountA,
      )
    }
  }
}
