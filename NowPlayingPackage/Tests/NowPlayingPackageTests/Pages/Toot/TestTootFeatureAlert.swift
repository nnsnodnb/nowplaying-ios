//
//  TestTootFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTootFeatureAlert {
  @Test
  func testPresentedDelete() async throws {
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: TootFeature.State(
          mastodonAccounts: [],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: nil,
          capturedImage: .init(systemSymbol: .photo),
          alert: AlertState(
            title: {
              TextState("テスト")
            },
            actions: {
              ButtonState(
                action: .close,
                label: {
                  TextState(.close)
                },
              )
            },
          )
        ),
        reducer: {
          TootFeature()
        },
      )

      await store.send(.alert(.presented(.delete))) {
        $0.alert = nil
      }
      #expect(calledDismiss)
    }
  }
}
