//
//  TestTwitterAccountManageFeatureAuthenticateSuccess.swift
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
struct TestTwitterAccountManageFeatureAuthenticateSuccess {
  @Test(
    .dependency(\.date, .constant(.now))
  )
  func testSuccess() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.twitterOAuth.validateCallbackURL = { _ in .init("stub_user_id") }
      $0.twitterAPI.getUserMe = { _ in twitterAccount.profile }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.addTwitterAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "https://testserver/oauth")!)) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.requestGetUserMe, .init("stub_user_id"))
      await store.receive(\.internalAction.savedTwitterAccount, twitterAccount.profile) {
        $0.isLoading = false
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
    .dependencies {
      $0.twitterOAuth.validateCallbackURL = { _ in throw TwitterOAuthClient.Error.invalidCallbackURL }
    }
  )
  func testInvalidCallbackURL() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.authenticateSuccess(URL(string: "https://testserver/oauth")!))
    await store.receive(\.internalAction.oauthFailure, String(localized: .anInvalidOperationWasPerformed)) {
      $0.alert = AlertState(
        title: {
          TextState(.anInvalidOperationWasPerformed)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.close)
            },
          )
        },
      )
    }
  }
}
