//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2026/03/04.
//

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
    Task {
      _ = try await Purchases.shared.logIn("$RCAnonymousID:9d6c93f9b9c0446c8c07fdc0a281b476")
    }
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
