//
//  TestPostFeatureSelectBlueskyAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestPostFeatureSelectBlueskyAccount {
  @Test
  func testPresentedDelegateSelectSameAccount() async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: false)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: true)
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
        selectBlueskyAccount: .init(
          blueskyAccounts: [blueskyAccountA, blueskyAccountB],
          selectedBlueskyAccount: blueskyAccountA,
        ),
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.selectBlueskyAccount(.presented(.delegate(.select(blueskyAccountA)))))
    await store.receive(\.selectBlueskyAccount.dismiss) {
      $0.selectBlueskyAccount = nil
    }
  }
}
