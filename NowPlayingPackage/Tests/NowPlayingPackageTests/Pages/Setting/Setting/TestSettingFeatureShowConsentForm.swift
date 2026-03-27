//
//  TestSettingFeatureShowConsentForm.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/27.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSettingFeatureShowConsentForm {
  @Test(
    .dependencies {
      $0.consentInformation.load = {}
      $0.consentInformation.presentPrivacyOptions = {}
      $0.consentInformation.loadAndPresentIfRequired = {}
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        visiblePrivacyOptionsRequirements: true,
        isLoadingConsentForm: false,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showConsentForm)
    await store.receive(\.internalAction.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.internalAction.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }

  @Test
  func testFailure() async throws {
    struct Error: Swift.Error {}

    await withDependencies {
      $0.consentInformation.load = {}
      $0.consentInformation.presentPrivacyOptions = { throw Error() }
      $0.consentInformation.loadAndPresentIfRequired = {}
    } operation: {
      let store = TestStore(
        initialState: SettingFeature.State(
          visiblePrivacyOptionsRequirements: true,
          isLoadingConsentForm: false,
        ),
        reducer: {
          SettingFeature()
        },
      )

      await store.send(.showConsentForm)
      await store.receive(\.internalAction.loadConsentForm) {
        $0.isLoadingConsentForm = true
      }
      await store.receive(\.internalAction.loadedConsentForm) {
        $0.isLoadingConsentForm = false
      }
    }
  }

  @Test(arguments: zip([true, false], [true, false]))
  func testEnoughRequirements(visiblePrivacyOptionsRequirements: Bool, isLoadingConsentForm: Bool) async throws {
    let store = TestStore(
      initialState: SettingFeature.State(
        visiblePrivacyOptionsRequirements: visiblePrivacyOptionsRequirements,
        isLoadingConsentForm: isLoadingConsentForm,
      ),
      reducer: {
        SettingFeature()
      },
    )

    await store.send(.showConsentForm)
  }
}
