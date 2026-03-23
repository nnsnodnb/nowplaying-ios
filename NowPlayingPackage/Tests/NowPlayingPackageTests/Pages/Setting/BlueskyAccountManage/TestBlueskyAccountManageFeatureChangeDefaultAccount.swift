//
//  TestBlueskyAccountManageFeatureChangeDefaultAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyAccountManageFeatureChangeDefaultAccount {
  @Test
  func testAlreadyDefault() async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: true)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: false)
    }

    let store = TestStore(
      initialState: BlueskyAccountManageFeature.State(
        blueskyAccounts: [blueskyAccountA, blueskyAccountB],
      ),
      reducer: {
        BlueskyAccountManageFeature()
      },
    )

    await store.send(.changeDefaultAccount(blueskyAccountA))
  }

  @Test
  func testChangeToDefault() async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: true)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: false)
    }
    let updatedBlueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: false)
    }
    let updatedBlueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.isDefault, value: true)
    }

    await withDependencies {
      $0.secureKeyValueStore.getBlueskyAccounts = { [updatedBlueskyAccountA, updatedBlueskyAccountB] }
      $0.secureKeyValueStore.updateDefaultBlueskyAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: BlueskyAccountManageFeature.State(
          blueskyAccounts: [blueskyAccountA, blueskyAccountB],
        ),
        reducer: {
          BlueskyAccountManageFeature()
        },
      )

      await store.send(.changeDefaultAccount(blueskyAccountB))
      await store.receive(\.fetchBlueskyAccounts)
      await store.receive(\.internalAction.fetchedBlueskyAccounts) {
        $0.blueskyAccounts = [updatedBlueskyAccountA, updatedBlueskyAccountB]
      }
    }
  }
}
