//
//  TestBlueskyLoginFeatureLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestBlueskyLoginFeatureLogin {
  @Test
  func testIsDisabledLoginButton() async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        isDisabledLoginButton: true,
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.login)
  }

  @Test
  func testIt() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await withDependencies {
      $0.blueskyAPI.login = { _, _ in blueskyAccount }
      $0.secureKeyValueStore.addBlueskyAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: BlueskyLoginFeature.State(
          handle: "example.bsky.app",
          password: "password",
          isDisabledLoginButton: false,
        ),
        reducer: {
          BlueskyLoginFeature()
        },
      )

      await store.send(.login) {
        $0.focusedField = nil
        $0.isLoading = true
      }
      await store.receive(\.internalAction.loggedIn, blueskyAccount) {
        $0.isLoading = false
      }
      await store.receive(\.delegate.loggedIn, blueskyAccount)
      await store.receive(\.close)
    }
  }

  @Test(
    arguments: zip(
      [
        BlueskyAPIClient.Error.invalidHandleOrPassword,
        BlueskyAPIClient.Error.invalidHandle,
        BlueskyAPIClient.Error.enabledTwoFactorAuthentication,
        BlueskyAPIClient.Error.unknown,
      ],
      [
        "ハンドルもしくはパスワードが間違っていませんか？",
        "ハンドルが間違っていませんか？",
        "2要素認証が有効になっています。アプリパスワードを入力してください",
        "不明なエラーが発生しました",
      ],
    )
  )
  func testErrorInvalidHandleOrPassword(error: BlueskyAPIClient.Error, message: String) async throws {
    await withDependencies {
      $0.blueskyAPI.login = { _, _ in throw error }
    } operation: {
      let store = TestStore(
        initialState: BlueskyLoginFeature.State(
          handle: "example.bsky.app",
          password: "password",
          isDisabledLoginButton: false,
        ),
        reducer: {
          BlueskyLoginFeature()
        },
      )

      await store.send(.login) {
        $0.focusedField = nil
        $0.isLoading = true
      }
      await store.receive(\.internalAction.loginFailure, message) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("エラーが発生しました")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
          message: {
            TextState(message)
          }
        )
      }
    }
  }
}
