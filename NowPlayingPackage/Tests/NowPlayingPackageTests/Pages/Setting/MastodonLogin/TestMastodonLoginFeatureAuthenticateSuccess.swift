//
//  TestMastodonLoginFeatureAuthenticateSuccess.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonLoginFeatureAuthenticateSuccess {
  @Test
  func testIt() async throws {
    let mastodonInstance = try Stub.make(MastodonInstance.self)
    let clientApplication = try Stub.make(MastodonClientApplication.self)
    let mastodonOAuthToken = try Stub.make(MastodonOAuthToken.self)
    let mastodonAccount = try Stub.make(MastodonAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mastodonOAuth.validateCallbackURL = { _, _ in .init("stub_authorization_code") }
      $0.mastodonOAuth.requestAccessToken = { _, _, _ in mastodonOAuthToken }
      $0.mastodonOAuth.verifyAccessToken = { _, _ in mastodonAccount }
      $0.secureKeyValueStore.addMastodonAccount = { _ in }
      $0.secureKeyValueStore.setMastodonOAuthToken = { _, _ in }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          callbackURLScheme: "test-scheme",
          isCheckButtonDisabled: false,
          domain: "example.com",
          mastodonInstance: mastodonInstance,
          codeVerifier: .init("stub_code_verifier"),
          clientApplication: clientApplication,
          isLoading: true,
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "test-scheme://callback/oauth?state=stub_state&code=stub_code")!))
      await store.receive(\.internalAction.savedMastodonAccount) {
        $0.isLoading = false
      }
      await store.receive(\.delegate.loggedIn, mastodonAccount)
      await store.receive(\.close)
      #expect(calledDismiss)
    }
  }

  @Test
  func testInvalidCallbackURL() async throws {
    let mastodonInstance = try Stub.make(MastodonInstance.self)
    let clientApplication = try Stub.make(MastodonClientApplication.self)

    await withDependencies {
      $0.mastodonOAuth.validateCallbackURL = { _, _ in throw MastodonOAuthClient.Error.invalidCallbackURL }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          callbackURLScheme: "test-scheme",
          isCheckButtonDisabled: false,
          domain: "example.com",
          mastodonInstance: mastodonInstance,
          codeVerifier: .init("stub_code_verifier"),
          clientApplication: clientApplication,
          isLoading: true,
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "test-scheme://callback/oauth?state=stub_state&code=stub_code")!))
      await store.receive(\.internalAction.oauthFailure, .anInvalidOperationWasPerformed) {
        $0.isLoading = false
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

  @Test
  func testInternalError() async throws {
    let mastodonInstance = try Stub.make(MastodonInstance.self)
    let clientApplication = try Stub.make(MastodonClientApplication.self)
    let mastodonOAuthToken = try Stub.make(MastodonOAuthToken.self)

    await withDependencies {
      $0.mastodonOAuth.validateCallbackURL = { _, _ in .init("stub_authorization_code") }
      $0.mastodonOAuth.requestAccessToken = { _, _, _ in mastodonOAuthToken }
      $0.mastodonOAuth.verifyAccessToken = { _, _ in throw MastodonOAuthClient.Error.internalError }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          callbackURLScheme: "test-scheme",
          isCheckButtonDisabled: false,
          domain: "example.com",
          mastodonInstance: mastodonInstance,
          codeVerifier: .init("stub_code_verifier"),
          clientApplication: clientApplication,
          isLoading: true,
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.authenticateSuccess(URL(string: "test-scheme://callback/oauth?state=stub_state&code=stub_code")!))
      await store.receive(\.internalAction.oauthFailure, .anUnknownErrorHasOccurred) {
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
