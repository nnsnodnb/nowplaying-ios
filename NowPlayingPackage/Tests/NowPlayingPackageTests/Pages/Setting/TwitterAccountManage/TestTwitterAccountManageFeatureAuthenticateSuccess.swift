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
      $0.twitterOAuth.validateCallbackURL = { _, _ in .init("stub_authorization_code") }
      $0.twitterOAuth.requestAccessToken = { _, _ in twitterAccount.oauthToken }
      $0.twitterOAuth.getAccessToken = { _ in .init("stub_access_token") }
      $0.twitterAPI.getUserMe = { _ in twitterAccount.profile }
      $0.secureKeyValueStore.addTwitterAccount = { _ in }
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
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
      await store.receive(\.internalAction.requestGetUserMe, twitterAccount.oauthToken)
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
      await store.receive(\.internalAction.oauthFailure, "認証情報の取得に失敗しました") {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("認証情報の取得に失敗しました")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("閉じる")
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
    await store.receive(\.internalAction.oauthFailure, "無効な操作が行われました") {
      $0.alert = AlertState(
        title: {
          TextState("無効な操作が行われました")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("閉じる")
            },
          )
        },
      )
    }
  }
}
