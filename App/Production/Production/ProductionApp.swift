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
  }
}
