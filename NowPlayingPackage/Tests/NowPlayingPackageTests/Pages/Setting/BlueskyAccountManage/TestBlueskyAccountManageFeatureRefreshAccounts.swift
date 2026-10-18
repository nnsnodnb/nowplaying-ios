//
//  TestBlueskyAccountManageFeatureRefreshAccounts.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/18.
//

import CommonModule
import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureRefreshAccounts {
  @Test
  func testSuccess() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    let identity = try Stub.make(BlueskyAccount.Identity.self)

    await withDependencies {
      $0.blueskyAPI.getUserProfile = { _, _ in blueskyAccount }
      $0.secureKeyValueStore.getBlueskyAccounts = { [blueskyAccount] }
      $0.secureKeyValueStore.setBlueskyAccounts = { _ in }
      $0.secureKeyValueStore.getBlueskyAccountIdentity = { _ in identity }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          blueskyAccounts: [blueskyAccount],
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.refreshAccounts) {
        $0.isRefreshing = true
      }
      await store.receive(\.internalAction.updatedBlueskyAccounts) {
        $0.isRefreshing = false
      }
      await store.receive(\.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts)
    }
  }

  @Test
  func testBlueskyAccountIsEmpty() async throws {
    let store = TestStore(
      initialState: BlueskyAccountManageFeature.State(
        blueskyAccounts: [],
      ),
      reducer: {
        BlueskyAccountManageFeature()
      },
    )

    await store.send(.refreshAccounts)
  }

  @Test
  func testFailed() async throws {
    struct Error: Swift::Error {}

    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    let identity = try Stub.make(BlueskyAccount.Identity.self)

    await withDependencies {
      $0.blueskyAPI.getUserProfile = { _, _ in throw Error() }
      $0.secureKeyValueStore.getBlueskyAccountIdentity = { _ in identity }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          blueskyAccounts: [blueskyAccount],
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.refreshAccounts) {
        $0.isRefreshing = true
      }
      await store.receive(\.internalAction.failedUpdateBlueskyAccounts) {
        $0.isRefreshing = false
        $0.alert = AlertState(
          title: {
            TextState(.failedToUpdateProfileInformation)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          }
        )
      }
    }
  }
}
