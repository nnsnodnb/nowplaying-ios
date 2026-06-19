//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2026/03/04.
//

import CommonModule
import DependenciesInterfaces
import DependenciesLive
import FirebaseAnalytics
import FirebaseCore
import GoogleMobileAds
import RevenueCat
import NowPlayingPackage

@main
struct AdHocApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      RootPage(
        store: .init(
          initialState: RootFeature.State(),
          reducer: {
            RootFeature()
          },
          withDependencies: {
            $0.adClient = .google
            $0.analytics = .firebase
            $0.appCheck = .firebase
            $0.auth = .firebase
            $0.blueskyAPI = .atProtoKit
            $0.consentInformation = .google
            $0.crashlytics = .firebase
            $0.functions = .firebase(endpointURLString: "https://asia-northeast1-nowplaying-dev.cloudfunctions.net")
            $0.revenueCat = .revenueCat
            $0.rewardedAd = .google
            $0.secureKeyValueStore = .keychainAccess
            if UserDefaults.standard.bool(forKey: "key_mock_twitter_api") {
              $0.twitterAPI.getUserMe = { _ in .nnsnodnb }
              $0.twitterAPI.uploadMedia = { _, _ in
                try await Task.sleep(for: .milliseconds(500))
                return TwitterMedia(
                  id: .init("2034250625912016896"),
                  expiresAfterSecs: 86_400,
                  expiresAt: Date.now.addingTimeInterval(86_400),
                )
              }
              $0.twitterAPI.post = { _, _, _ in
                try await Task.sleep(for: .milliseconds(200))
              }
            }
          }
        ),
      )
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "AA95B3D2-DAFF-4180-AC85-DB86E193D628",
        "7CDBDCE8-ECF8-4372-B21D-1A1E0F2176A2",
      ]
    }
    Purchases.configure(withAPIKey: "appl_bFpdFCHLAyHiwuozSKJgbMNPZkD")
    Task {
      _ = try await Purchases.shared.logIn("$RCAnonymousID:9d6c93f9b9c0446c8c07fdc0a281b476")
    }
    Analytics.setUserID(Purchases.shared.appUserID)
    if let appInstanceID = Analytics.appInstanceID() {
      Purchases.shared.attribution.setFirebaseAppInstanceID(appInstanceID)
    }
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
