//
//  TestSettingFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeatureOnAppear {
  @Test(
    .dependencies {
      $0.bundle.shortVersionString = { "1.0.0-test" }
      $0.consentInformation.visiblePrivacyOptionsRequirements = { false }
    }
  )
  func testConsentInformationVisiblePrivacyOptionsRequirementsIsFalse() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.onAppear) {
      $0.version = "1.0.0-test"
      $0.visiblePrivacyOptionsRequirements = false
    }
  }

  @Test(
    .dependencies {
      $0.bundle.shortVersionString = { "1.0.0-test" }
      $0.consentInformation.visiblePrivacyOptionsRequirements = { true }
      $0.consentInformation.load = {}
    }
  )
  func testConsentInformationVisiblePrivacyOptionsRequirementsIsTrue() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.onAppear) {
      $0.version = "1.0.0-test"
      $0.visiblePrivacyOptionsRequirements = true
    }
    await store.receive(\.internalAction.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.internalAction.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }
}
