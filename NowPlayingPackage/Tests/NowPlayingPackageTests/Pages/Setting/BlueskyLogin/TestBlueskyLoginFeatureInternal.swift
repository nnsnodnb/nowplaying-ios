//
//  TestBlueskyLoginFeatureInternal.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestBlueskyLoginFeatureInternal {
  @Test
  func testInternalValidateEnabled() async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        handle: "example.bsky.social",
        password: "password",
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.internalAction(.validate)) {
      $0.isDisabledLoginButton = false
    }
  }

  @Test(arguments: [" ", "\n"])
  func testInternalValidateDisabledHandleIsWhitespaceAndNewLines(handle: String) async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        handle: handle,
        password: "password",
        isDisabledLoginButton: false,
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.internalAction(.validate)) {
      $0.isDisabledLoginButton = true
    }
  }

  @Test(arguments: [" ", "\n"])
  func testInternalValidateDisabledPasswordIsWhitespaceAndNewLines(password: String) async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        handle: "example.bsky.social",
        password: password,
        isDisabledLoginButton: false,
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.internalAction(.validate)) {
      $0.isDisabledLoginButton = true
    }
  }

  @Test(arguments: [" ", "\n"], [" ", "\n"])
  func testInternalValidateDisabledWhitespacesAndNewlines(handle: String, password: String) async throws {
    let store = TestStore(
      initialState: BlueskyLoginFeature.State(
        handle: handle,
        password: password,
        isDisabledLoginButton: false,
      ),
      reducer: {
        BlueskyLoginFeature()
      },
    )

    await store.send(.internalAction(.validate)) {
      $0.isDisabledLoginButton = true
    }
  }
}
