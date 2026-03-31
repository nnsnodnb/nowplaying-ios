//
//  TestPostFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPostFeatureAlert {
  @Test
  func testPresentedDelete() async throws {
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: PostFeature.State(
          blueskyAccounts: [],
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
          PostFeature()
        },
      )

      await store.send(.alert(.presented(.delete))) {
        $0.alert = nil
      }
      #expect(calledDismiss)
    }
  }
}
