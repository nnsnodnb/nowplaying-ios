//
//  TestBlueskyAccountManageFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/18.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestBlueskyAccountManageFeatureAlert {
  @Test
  func testPresentedReset() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getBlueskyAccounts = { [] }
      $0.secureKeyValueStore.setBlueskyAccounts = { _ in }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          alert: AlertState(
            title: {
              TextState("Test")
            },
            actions: {
              ButtonState(
                action: .reset,
                label: {
                  TextState(.okay)
                },
              )
            },
          )
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.alert(.presented(.reset))) {
        $0.alert = nil
      }
      await store.receive(\.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts, [])
    }
  }
}
