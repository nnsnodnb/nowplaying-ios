//
//  ConsentInformationClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import Foundation
import UserMessagingPlatform

public extension ConsentInformationClient {
  static let google: ConsentInformationClient = .init(
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
