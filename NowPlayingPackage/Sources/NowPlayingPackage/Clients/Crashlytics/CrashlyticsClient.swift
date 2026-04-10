//
//  CrashlyticsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/10.
//

import Dependencies
import DependenciesMacros
import FirebaseCrashlytics
import Foundation
import GoogleMobileAds

@DependencyClient
public struct CrashlyticsClient: Sendable {
  public var recordAdBannerLoadError: @Sendable (sending ResponseInfo?, any Error) throws -> Void
  public var recordRewardedAdLoadError: @Sendable (any Error) throws -> Void
}

// MARK: - DependencyKey
extension CrashlyticsClient: DependencyKey {
  public static let liveValue: Self = .init(
    recordAdBannerLoadError: { responseInfo, error in
      if let responseInfo {
        if let responseIdentifier = responseInfo.responseIdentifier {
          Crashlytics.crashlytics().setCustomValue(responseIdentifier, forKey: "banner_ad_response_id")
        }
        if let adNetworkClassName = responseInfo.adNetworkInfoArray.first?.adNetworkClassName {
          Crashlytics.crashlytics().setCustomValue(adNetworkClassName, forKey: "banner_ad_network_class_name")
        }
      }
      let nsError = error as NSError
      Crashlytics.crashlytics().setCustomValue(nsError.code, forKey: "banner_ad_error_code")
      Crashlytics.crashlytics().record(error: error)
    },
    recordRewardedAdLoadError: { error in
      let nsError = error as NSError
      Crashlytics.crashlytics().setCustomValue("", forKey: "rewarded_ad_response_id")
      Crashlytics.crashlytics().setCustomValue("", forKey: "rewarded_ad_network_class_name")
      Crashlytics.crashlytics().setCustomValue(nsError.code, forKey: "rewarded_ad_error_code")
      Crashlytics.crashlytics().setCustomValue(nsError.domain, forKey: "rewarded_ad_error_domain")
      Crashlytics.crashlytics().record(error: nsError)
    },
  )
  public static let testValue: Self = .init(
    recordAdBannerLoadError: { _, _ in },
    recordRewardedAdLoadError: { _ in },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var crashlytics: CrashlyticsClient {
    get {
      self[CrashlyticsClient.self]
    }
    set {
      self[CrashlyticsClient.self] = newValue
    }
  }
}
