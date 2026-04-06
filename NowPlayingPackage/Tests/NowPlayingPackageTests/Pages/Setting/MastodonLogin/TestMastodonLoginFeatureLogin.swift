//
//  TestMastodonLoginFeatureLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonLoginFeatureLogin {
  @Test
  func testIt() async throws {
    let clientApplication = try Stub.make(MastodonClientApplication.self)

    await withDependencies {
      $0.mastodonAPI.registerApplication = { _ in clientApplication }
      $0.mastodonOAuth.getAuthenticateURL = { _ in
        (URL(string: "https://testserver/oauth/authorize")!, .init("stub_code_verifier"))
      }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          callbackURLScheme: "test-scheme",
          isCheckButtonDisabled: false,
          domain: "example.com",
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.login) {
        $0.isLoading = true
        $0.isFocused = false
      }
      await store.receive(\.internalAction.startOAuth) {
        $0.oauthURL = URL(string: "https://testserver/oauth/authorize")!
        $0.codeVerifier = .init("stub_code_verifier")
        $0.clientApplication = clientApplication
      }
    }
  }

  @Test
  func testFailure() async throws {
    await withDependencies {
      struct Error: Swift.Error {}

      $0.mastodonAPI.registerApplication = { _ in throw Error() }
      $0.mastodonOAuth.getAuthenticateURL = { _ in
        (URL(string: "https://testserver/oauth/authorize")!, .init("stub_code_verifier"))
      }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          callbackURLScheme: "test-scheme",
          isCheckButtonDisabled: false,
          domain: "example.com",
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.login) {
        $0.isLoading = true
        $0.isFocused = false
      }
      await store.receive(\.internalAction.oauthFailure) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState(.anUnknownErrorHasOccurred)
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
}
