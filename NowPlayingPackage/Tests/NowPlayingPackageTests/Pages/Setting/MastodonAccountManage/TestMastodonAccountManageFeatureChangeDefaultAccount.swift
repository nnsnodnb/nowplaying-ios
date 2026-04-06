//
//  TestMastodonAccountManageFeatureChangeDefaultAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonAccountManageFeatureChangeDefaultAccount {
  @Test
  func testAlreadyDefault() async throws {
    let mastodonAccountA = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: true)
    }
    let mastodonAccountB = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: false)
    }

    let store = TestStore(
      initialState: MastodonAccountManageFeature.State(
        mastodonAccounts: [mastodonAccountA, mastodonAccountB],
      ),
      reducer: {
        MastodonAccountManageFeature()
      },
    )

    await store.send(.changeDefaultAccount(mastodonAccountA))
  }

  @Test
  func testChangeToDefault() async throws {
    let mastodonAccountA = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: true)
    }
    let mastodonAccountB = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: false)
    }
    let updatedMastodonAccountA = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: false)
    }
    let updatedMastodonAccountB = try Stub.make(MastodonAccount.self) {
      $0.set(\.isDefault, value: true)
    }

    await withDependencies {
      $0.secureKeyValueStore.getMastodonAccounts = { [updatedMastodonAccountA, updatedMastodonAccountB] }
      $0.secureKeyValueStore.updateDefaultMastodonAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MastodonAccountManageFeature.State(
          mastodonAccounts: [mastodonAccountA, mastodonAccountB],
        ),
        reducer: {
          MastodonAccountManageFeature()
        },
      )

      await store.send(.changeDefaultAccount(mastodonAccountB))
      await store.receive(\.fetchMastodonAccounts)
      await store.receive(\.internalAction.fetchedMastodonAccounts) {
        $0.mastodonAccounts = [updatedMastodonAccountA, updatedMastodonAccountB]
      }
    }
  }
}
