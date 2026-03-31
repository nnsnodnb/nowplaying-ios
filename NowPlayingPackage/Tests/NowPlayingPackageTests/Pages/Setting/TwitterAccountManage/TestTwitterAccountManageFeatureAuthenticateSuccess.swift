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
    let twitterOAuthToken = try Stub.make(TwitterOAuthToken.self)

    await withDependencies {
      $0.twitterOAuth.validateCallbackURL = { _, _ in .init("stub_authorization_code") }
      $0.twitterOAuth.requestAccessToken = { _, _ in twitterOAuthToken }
      $0.twitterAPI.getUserMe = { _ in twitterAccount.profile }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.addTwitterAccount = { _ in }
      $0.secureKeyValueStore.setTwitterOAuthToken = { _, _ in }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          codeVerifier: .init("stub_code_verifier"),
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "https://testserver/oauth")!)) {
        $0.isLoading = true
        $0.codeVerifier = nil
      }
      await store.receive(\.internalAction.requestGetUserMe, twitterOAuthToken)
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
    .dependency(\.date, .constant(.now))
  )
  func testFailureRequestAccessToken() async throws {
    await withDependencies {
      $0.twitterOAuth.validateCallbackURL = { _, _ in .init("stub_authorization_code") }
      $0.twitterOAuth.requestAccessToken = { _, _ in throw TwitterOAuthClient.Error.internalError }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          codeVerifier: .init("stub_code_verifier"),
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "https://testserver/oauth")!)) {
        $0.isLoading = true
        $0.codeVerifier = nil
      }
      await store.receive(\.internalAction.oauthFailure, String(localized: .failedToRetrieveAuthenticationInformation)) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState(.failedToRetrieveAuthenticationInformation)
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

  @Test
  func testCodeVerifierIsNil() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        codeVerifier: nil,
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.authenticateSuccess(URL(string: "https://testserver/oauth")!))
  }

  @Test(
    .dependencies {
      $0.twitterOAuth.validateCallbackURL = { _, _ in throw TwitterOAuthClient.Error.invalidCallbackURL }
    }
  )
  func testInvalidCallbackURL() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        codeVerifier: .init("stub_code_verifier"),
      ),
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
