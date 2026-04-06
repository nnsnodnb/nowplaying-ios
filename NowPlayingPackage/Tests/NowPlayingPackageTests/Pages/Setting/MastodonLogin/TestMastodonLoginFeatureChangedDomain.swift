//
//  TestMastodonLoginFeatureChangedDomain.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestMastodonLoginFeatureChangedDomain {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.changedDomain("example.com")) {
      $0.domain = "example.com"
      $0.isCheckButtonDisabled = false
    }
  }

  @Test
  func testToEmpty() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(
        isCheckButtonDisabled: false,
        domain: "example.com",
      ),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.changedDomain("")) {
      $0.domain = ""
      $0.isCheckButtonDisabled = true
    }
  }

  @Test
  func testWhitespaces() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(
        isCheckButtonDisabled: true,
        domain: "",
      ),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.changedDomain(" ")) {
      $0.domain = " "
    }
  }
}
