//
//  TestTwitterAccountManageFeatureInternalAction.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTwitterAccountManageFeatureInternalAction {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testRequestGetUserMe() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.twitterOAuth.requestAccessToken = { _, _ in twitterAccount.oauthToken }
      $0.twitterAPI.getUserMe = { _ in twitterAccount.profile }
      $0.secureKeyValueStore.addTwitterAccount = { _ in }
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          isLoading: true,
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.internalAction(.requestGetUserMe(twitterAccount.oauthToken)))
      await store.receive(\.internalAction.savedTwitterAccount, twitterAccount.profile) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("ログインしました！")
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
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          isLoading: true,
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.internalAction(.savedTwitterAccount(twitterAccount.profile))) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("ログインしました！")
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
