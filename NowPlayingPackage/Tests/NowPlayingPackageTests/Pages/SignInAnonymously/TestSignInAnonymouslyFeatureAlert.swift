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
  func testPresentedRetry() async throws {
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
                action: .retry,
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

      await store.send(.alert(.presented(.retry))) {
        $0.alert = nil
      }
      await mainQueue.advance(by: .milliseconds(400))
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.delegate.completed)
    }
  }
}
