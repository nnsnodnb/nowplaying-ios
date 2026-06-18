//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2026/03/04.
//

import DependenciesInterfaces
import DependenciesLive
import FirebaseAnalytics
import FirebaseCore
import GoogleMobileAds
import NowPlayingPackage
import RevenueCat

@main
struct ProductionApp: App {
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
            $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3417597686353524/5779812351" }
            $0.adUnit.addTwitterAccountRewardAdUnitID = { "ca-app-pub-3417597686353524/2100996522" }
            $0.adUnit.getFreePostTicketRewardAdUnitID = { "ca-app-pub-3417597686353524/7896895487" }
            $0.adClient = .google
            $0.analytics = .firebase
            $0.appCheck = .firebase
            $0.auth = .firebase
            $0.blueskyAPI = .atProtoKit
            $0.consentInformation = .google
            $0.crashlytics = .firebase
            $0.functions = .firebase()
            $0.revenueCat = .revenueCat
            $0.rewardedAd = .google
            $0.secureKeyValueStore = .keychainAccess
          },
        ),
      )
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
    }
    Purchases.configure(withAPIKey: "appl_bFpdFCHLAyHiwuozSKJgbMNPZkD")
    Analytics.setUserID(Purchases.shared.appUserID)
    if let appInstanceID = Analytics.appInstanceID() {
      Purchases.shared.attribution.setFirebaseAppInstanceID(appInstanceID)
    }
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
