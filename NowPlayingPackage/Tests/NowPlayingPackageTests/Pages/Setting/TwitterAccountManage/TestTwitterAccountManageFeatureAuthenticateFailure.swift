//
//  TestTwitterAccountManageFeatureAuthenticateFailure.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import AuthenticationServices
import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureAuthenticateFailure {
  @Test
  func testErrorCodeCanceledLogin() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    let error = NSError(
      domain: ASWebAuthenticationSessionErrorDomain,
      code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
    )
    await store.send(.authenticateFailure(error))
  }

  @Test(
    arguments: [
      ASWebAuthenticationSessionError.Code.presentationContextInvalid,
      ASWebAuthenticationSessionError.Code.presentationContextNotProvided,
    ],
  )
  func testErrorCodeNotCanceldLogin(errorCode: ASWebAuthenticationSessionError.Code) async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    let error = NSError(domain: ASWebAuthenticationSessionErrorDomain, code: errorCode.rawValue)
    await store.send(.authenticateFailure(error))
    await store.receive(\.internalAction.oauthFailure) {
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
