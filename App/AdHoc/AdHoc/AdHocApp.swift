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
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "AA95B3D2-DAFF-4180-AC85-DB86E193D628",
        "7CDBDCE8-ECF8-4372-B21D-1A1E0F2176A2",
      ]
    }
    Purchases.configure(withAPIKey: "appl_bFpdFCHLAyHiwuozSKJgbMNPZkD")
    Task {
      _ = try await Purchases.shared.logIn("$RCAnonymousID:9d6c93f9b9c0446c8c07fdc0a281b476")
    }
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
