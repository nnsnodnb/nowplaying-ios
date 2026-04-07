//
//  TestTootFeatureClose.swift
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
struct TestTootFeatureClose {
  @Test
  func testIsEditing() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)

    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [mastodonAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        isEditing: true,
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.close) {
      $0.alert = AlertState(
        title: {
          TextState(.deleteToot)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.cancel)
            },
          )
          ButtonState(
            role: .destructive,
            action: .delete,
            label: {
              TextState(.delete)
            },
          )
        },
      )
    }
  }

  @Test
  func testIsNotEditing() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: TootFeature.State(
          mastodonAccounts: [mastodonAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          isEditing: false,
        ),
        reducer: {
          TootFeature()
        },
      )

      await store.send(.close)
      #expect(calledDismiss)
    }
  }
}
