//
//  ConsentInformationClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import Dependencies
import DependenciesMacros
import Foundation
import UserMessagingPlatform

@DependencyClient
public struct ConsentInformationClient: Sendable {
  public var requestConsent: @Sendable () async throws -> Bool
  public var load: @Sendable () async throws -> Void
  public var loadAndPresentIfRequired: @Sendable () async throws -> Void
  public var visiblePrivacyOptionsRequirements: @Sendable () -> Bool = { false }
  public var presentPrivacyOptions: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension ConsentInformationClient: DependencyKey {
  public static let liveValue: ConsentInformationClient = .init(
    requestConsent: {
      let parameters = RequestParameters()
#if DEBUG
      let debugSettings = DebugSettings()
      debugSettings.geography = .EEA
      parameters.debugSettings = debugSettings
#endif
      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .required else { return false }
      let status = ConsentInformation.shared.formStatus == .available
      return status
    },
    load: { @MainActor in
      try await ConsentForm.load()
    },
    loadAndPresentIfRequired: { @MainActor in
      try await ConsentForm.loadAndPresentIfRequired(from: nil)
    },
    visiblePrivacyOptionsRequirements: {
      ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    },
    presentPrivacyOptions: { @MainActor in
      let parameters = RequestParameters()
#if DEBUG
      let debugSettings = DebugSettings()
      debugSettings.geography = .EEA
      parameters.debugSettings = debugSettings
#endif
      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .obtained else { return }
      try await ConsentForm.presentPrivacyOptionsForm(from: nil)
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var consentInformation: ConsentInformationClient {
    get {
      self[ConsentInformationClient.self]
    }
    set {
      self[ConsentInformationClient.self] = newValue
    }
  }
}
