//
//  TestBlueskyLoginFeatureLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import CommonModule
import ComposableArchitecture
import DependenciesInterfaces
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
    let identity = try Stub.make(BlueskyAccount.Identity.self)
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await withDependencies {
      $0.blueskyOAuth.resolveIdentity = { _ in identity }
      $0.blueskyOAuth.makeAuthenticator = { _, _, _ in StubAuthenticator() }
      $0.blueskyAPI.getUserProfile = { _, _ in blueskyAccount }
      $0.secureKeyValueStore.addBlueskyAccount = { _ in }
      $0.secureKeyValueStore.getBlueskyAccountPrivateKey = { _ in .init() }
      $0.secureKeyValueStore.setBlueskyAccountIdentity = { _ in }
    } operation: {
      let store = TestStore(
        initialState: BlueskyLoginFeature.State(
          handle: "example.bsky.social",
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
}
