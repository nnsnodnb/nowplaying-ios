//
//  TestSettingFeatureOpenSafari.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeatureOpenSafari {
  @Test(
    arguments: [
      SettingFeature.State.SafariURL.contactDeveloper,
      SettingFeature.State.SafariURL.gitHub,
      SettingFeature.State.SafariURL.googleForm,
      SettingFeature.State.SafariURL.reviewAppStore,
    ]
  )
  func testToSome(safariURL: SettingFeature.State.SafariURL) async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.openSafari(safariURL)) {
      $0.safariURL = safariURL
    }
  }

  @Test
  func testToNone() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        safariURL: .contactDeveloper,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.openSafari(nil)) {
      $0.safariURL = nil
    }
  }
}
