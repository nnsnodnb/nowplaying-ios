//
//  TestTwitterAccountManageFeatureChangeDefaultAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.date, .constant(.now))
)
struct TestTwitterAccountManageFeatureChangeDefaultAccount {
  @Test
  func testAlreadyDefault() async throws {
    let twitterProfileA = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_a"))
    }
    let twitterAccountA = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileA)
      $0.set(\.isDefault, value: true)
    }
    let twitterProfileB = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_b"))
    }
    let twitterAccountB = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileB)
    }

    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        twitterAccounts: [twitterAccountA, twitterAccountB],
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.changeDefaultAccount(twitterAccountA))
  }

  @Test
  func testChangeToDefault() async throws {
    let twitterProfileA = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_a"))
    }
    let twitterAccountA = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileA)
      $0.set(\.isDefault, value: true)
    }
    let twitterProfileB = try Stub.make(TwitterProfile.self) {
      $0.set(\.id, value: .init("stub_id_b"))
    }
    let twitterAccountB = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileB)
      $0.set(\.isDefault, value: false)
    }
    let updatedNotDefaultTwitterAccount = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileA)
      $0.set(\.isDefault, value: false)
    }
    let updatedDefaultTwitterAccount = try Stub.make(TwitterAccount.self) {
      $0.set(\.profile, value: twitterProfileB)
      $0.set(\.isDefault, value: true)
    }

    await withDependencies {
      $0.secureKeyValueStore.updateDefaultTwitterAccount = { _ in }
      $0.secureKeyValueStore.twitterAccounts = { [updatedNotDefaultTwitterAccount, updatedDefaultTwitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          twitterAccounts: [twitterAccountA, twitterAccountB],
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.changeDefaultAccount(twitterAccountB))
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts) {
        $0.twitterAccounts = [updatedNotDefaultTwitterAccount, updatedDefaultTwitterAccount]
      }
    }
  }
}
