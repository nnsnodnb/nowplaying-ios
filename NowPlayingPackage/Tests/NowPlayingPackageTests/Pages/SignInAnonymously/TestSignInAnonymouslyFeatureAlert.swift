//
//  TestSignInAnonymouslyFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/14.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestSignInAnonymouslyFeatureAlert {
  @Test
  func testPresentedRetryDeleteUser() async throws {
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.auth.signInAnonymously = {}
      $0.auth.signOut = {}
      $0.functions.deleteAnonymouslyUser = {}
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(
          alert: AlertState(
            title: {
              TextState(.failedLoad)
            },
            actions: {
              ButtonState(
                action: .retryDeleteUser,
                label: {
                  TextState(.retry)
                },
              )
            },
          ),
        ),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.alert(.presented(.retryDeleteUser))) {
        $0.alert = nil
      }
      await mainQueue.advance(by: .milliseconds(400))
      await store.receive(\.internalAction.deletePreviousAnonymouslyUser)
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testPresentedRetrySignIn() async throws {
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.auth.signInAnonymously = {}
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(
          alert: AlertState(
            title: {
              TextState(.failedLoad)
            },
            actions: {
              ButtonState(
                action: .retrySignIn,
                label: {
                  TextState(.retry)
                },
              )
            },
          ),
        ),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.alert(.presented(.retrySignIn))) {
        $0.alert = nil
      }
      await mainQueue.advance(by: .milliseconds(400))
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.delegate.completed)
    }
  }
}
