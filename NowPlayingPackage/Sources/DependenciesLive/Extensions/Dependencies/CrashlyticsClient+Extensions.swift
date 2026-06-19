//
//  CrashlyticsClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import FirebaseCrashlytics
import Foundation

public extension CrashlyticsClient {
  static let firebase: Self = .init(
    recordAdBannerLoadError: { responseInfo, error in
      if let responseInfo {
        if let responseIdentifier = responseInfo.responseIdentifier {
          Crashlytics.crashlytics().setCustomValue(responseIdentifier, forKey: "banner_ad_response_id")
        }
        if let adNetworkClassName = responseInfo.adNetworkInfo.first?.adNetworkClassName {
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
}
