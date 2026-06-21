//
//  TestTwitterAccountManageFeatureInternalAction.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import CommonModule
import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTwitterAccountManageFeatureInternalAction {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testRequestGetUserMe() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.getUserMe = { _ in twitterAccount.profile }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.addTwitterAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          isLoading: true,
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.internalAction(.requestGetUserMe(.init("stub_user_id"))))
      await store.receive(\.internalAction.savedTwitterAccount, twitterAccount.profile) {
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.internalAction.showSuccessAlert) {
        $0.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("\(twitterAccount.profile.name) (@\(twitterAccount.profile.username))")
          },
        )
      }
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts, [twitterAccount]) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }

  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testSavedTwitterAccount() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
    } operation: {
      @Shared(.appStorage(.freeTwitterLoginCount))
      var freeTwitterLoginCount = 1

      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          isLoading: true,
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.internalAction(.savedTwitterAccount(twitterAccount.profile))) {
        $0.$freeTwitterLoginCount.withLock { $0 = 0 }
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.internalAction.showSuccessAlert) {
        $0.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("\(twitterAccount.profile.name) (@\(twitterAccount.profile.username))")
          },
        )
      }
      await store.receive(\.fetchTwitterAccounts)
      await store.receive(\.internalAction.fetchedTwitterAccounts) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }
}
