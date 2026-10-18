//
//  TestBlueskyAccountManageFeatureOnAppear.swift
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
struct TestBlueskyAccountManageFeatureOnAppear {
  @Test
  func testHasLegacyAccounts() async throws {
    await withDependencies {
      $0.secureKeyValueStore.hasLegacyBlueskyAccounts = { true }
    } operation: {
      @Shared(.appStorage(.blueskyLegacyAccountsMissingAlert))
      var blueskyLegacyAccountsMissingAlert = false

      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showSorryAlertForLegacyIfNeeded, true) {
        $0.alert = AlertState(
          title: {
            TextState(.blueskyAccountsMissingAlertTitle)
          },
          actions: {
            ButtonState(
              action: .reset,
              label: {
                TextState(.okay)
              },
            )
          },
          message: {
            TextState(.blueskyAccountsMissingAlertMessage)
          },
        )
        $0.$blueskyLegacyAccountsMissingAlert.withLock { $0 = true }
      }
    }
  }

  @Test
  func testHasLegacyAccountsButAlreadyShowedMissingAlert() async throws {
    await withDependencies {
      $0.secureKeyValueStore.hasLegacyBlueskyAccounts = { true }
    } operation: {
      @Shared(.appStorage(.blueskyLegacyAccountsMissingAlert))
      var blueskyLegacyAccountsMissingAlert = true

      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.onAppear)
    }
  }

  @Test
  func testNotHaveLegacyAccounts() async throws {
    await withDependencies {
      $0.secureKeyValueStore.hasLegacyBlueskyAccounts = { false }
    } operation: {
      @Shared(.appStorage(.blueskyLegacyAccountsMissingAlert))
      var blueskyLegacyAccountsMissingAlert = false

      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showSorryAlertForLegacyIfNeeded, false) {
        $0.$blueskyLegacyAccountsMissingAlert.withLock { $0 = true }
      }
    }
  }

  @Test
  func testNotHaveLegacyAccountsAndAlreadyShowedMissingAlert() async throws {
    await withDependencies {
      $0.secureKeyValueStore.hasLegacyBlueskyAccounts = { false }
    } operation: {
      @Shared(.appStorage(.blueskyLegacyAccountsMissingAlert))
      var blueskyLegacyAccountsMissingAlert = true

      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.onAppear)
    }
  }
}
