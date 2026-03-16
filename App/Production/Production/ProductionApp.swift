//
//  ProductionApp.swift
//  Production
//
//  Created by Yuya Oka on 2026/03/04.
//

import NowPlayingPackage

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
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
