//
//  TestMastodonAccountManageFeatureRefreshAccounts.swift
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
struct TestMastodonAccountManageFeatureRefreshAccounts {
  @Test
  func testSuccess() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await withDependencies {
      $0.mastodonOAuth.getAccessToken = { _ in .init("stub_access_token") }
      $0.mastodonAPI.getUserProfile = { _, _ in mastodonAccount }
      $0.secureKeyValueStore.getMastodonAccounts = { [mastodonAccount] }
      $0.secureKeyValueStore.setMastodonAccounts = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(
          mastodonAccounts: [mastodonAccount],
        ),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.refreshAccounts) {
        $0.isRefreshing = true
      }
      await store.receive(\.internalAction.updatedMastodonAccounts) {
        $0.isRefreshing = false
      }
      await store.receive(\.fetchMastodonAccounts)
      await store.receive(\.internalAction.fetchedMastodonAccounts)
    }
  }

  @Test
  func testMastodonAccountsIsEmpty() async throws {
    let store = TestStore(
      initialState: MastodonAccountManageFeature.State(
        mastodonAccounts: [],
      ),
      reducer: {
        MastodonAccountManageFeature()
      },
    )

    await store.send(.refreshAccounts)
  }

  @Test
  func testFailed() async throws {
    struct Error: Swift::Error {}

    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await withDependencies {
      $0.mastodonOAuth.getAccessToken = { _ in .init("stub_access_token") }
      $0.mastodonAPI.getUserProfile = { _, _ in throw Error() }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(
          mastodonAccounts: [mastodonAccount],
        ),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.refreshAccounts) {
        $0.isRefreshing = true
      }
      await store.receive(\.internalAction.failedUpdateMastodonAccount) {
        $0.isRefreshing = false
        $0.alert = AlertState(
          title: {
            TextState(.failedToRetrieveUserInformation)
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
      }
    }
  }
}
