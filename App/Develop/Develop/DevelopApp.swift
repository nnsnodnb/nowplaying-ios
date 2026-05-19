//
//  DevelopApp.swift
//  Develop
//
//  Created by Yuya Oka on 2026/03/04.
//

import NowPlayingPackage

@main
struct DevelopApp: App {
  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      if !isTesting {
        RootPage(
          store: .init(
            initialState: RootFeature.State(),
            reducer: {
              RootFeature()
            },
            withDependencies: {
              $0.twitterOAuth.getAuthenticateURL = {
                @Dependency(\.auth)
                var auth

                guard let uid = auth.currentUserID() else {
                  fatalError("Should logged in")
                }
                return URL(string: "http://127.0.0.1:9095/nowplaying-dev/asia-northeast1/twitter_oauth_init?uid=\(uid)")!
              }
              // MEMO: 普段はこれを有効にしておく
              $0.twitterAPI.uploadMedia = { _, _ in
                TwitterMedia(
                  id: .init("2034250625912016896"),
                  expiresAfterSecs: 86_400,
                  expiresAt: Date.now.addingTimeInterval(86_400),
                )
              }
              $0.twitterAPI.post = { _, _, _ in
                try await Task.sleep(for: .milliseconds(500))
              }
            }
          ),
        )
      }
    }
  }

  // MARK: - Initialize
  init() {
    #if DEBUG
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    #endif

    FirebaseApp.configure()
    #if DEBUG
    let host = "127.0.0.1"
    Auth.auth().useEmulator(withHost: host, port: 9091)
    Functions.functions(region: "asia-northeast1").useEmulator(withHost: host, port: 9095)
    #endif

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
