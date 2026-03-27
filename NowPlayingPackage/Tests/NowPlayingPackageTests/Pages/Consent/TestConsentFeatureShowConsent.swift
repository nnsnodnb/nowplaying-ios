//
//  TestConsentFeatureShowConsent.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestConsentFeatureShowConsent {
  @Test(
    .dependencies {
      $0.consentInformation.requestConsent = { true }
      $0.consentInformation.loadAndPresentIfRequired = {}
    }
  )
  func testShowConsentRequestConsentIsAvailable() async throws {
    let store = TestStore(
      initialState: ConsentFeature.State(),
      reducer: {
        ConsentFeature()
      },
    )

    await store.send(.showConsent)
    await store.receive(\.completed)
    await store.receive(\.delegate.completedConsent)
  }

  @Test(
    .dependencies {
      $0.consentInformation.requestConsent = { false }
      $0.consentInformation.loadAndPresentIfRequired = {}
    }
  )
  func testShowConsentRequestConsentIsNotAvailable() async throws {
    let store = TestStore(
      initialState: ConsentFeature.State(),
      reducer: {
        ConsentFeature()
      },
    )

    await store.send(.showConsent)
    await store.receive(\.completed)
    await store.receive(\.delegate.completedConsent)
  }
}
