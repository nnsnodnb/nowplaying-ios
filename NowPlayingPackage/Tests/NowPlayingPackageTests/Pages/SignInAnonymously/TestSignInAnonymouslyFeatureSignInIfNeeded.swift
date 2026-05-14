//
//  TestSignInAnonymouslyFeatureSignInIfNeeded.swift
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
struct TestSignInAnonymouslyFeatureSignInIfNeeded {
  @Test
  func testIt() async throws {
    await withDependencies {
      $0.auth.isSignedIn = { false }
      $0.auth.isAnonymous = { false }
      $0.auth.signInAnonymously = {}
      $0.auth.signOut = {}
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.signInIfNeeded)
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testIsSignedInAndIsAnonymous() async throws {
    await withDependencies {
      $0.auth.isSignedIn = { true }
      $0.auth.isAnonymous = { true }
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.signInIfNeeded)
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testIsSignedInAndIsNotAnonymous() async throws {
    await withDependencies {
      $0.auth.isSignedIn = { true }
      $0.auth.isAnonymous = { false }
      $0.auth.signOut = {}
      $0.auth.signInAnonymously = {}
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.signInIfNeeded)
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testSignInAnonymouslyFailure() async throws {
    struct Error: Swift.Error {}

    await withDependencies {
      $0.auth.isSignedIn = { false }
      $0.auth.isAnonymous = { false }
      $0.auth.signInAnonymously = { throw Error() }
      $0.auth.signOut = {}
    } operation: {
      let store = TestStore(
        initialState: SignInAnonymouslyFeature.State(),
        reducer: {
          SignInAnonymouslyFeature()
        },
      )

      await store.send(.signInIfNeeded)
      await store.receive(\.internalAction.signInAnonymously)
      await store.receive(\.internalAction.signInFailure) {
        $0.alert = AlertState(
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
        )
      }
    }
  }
}
