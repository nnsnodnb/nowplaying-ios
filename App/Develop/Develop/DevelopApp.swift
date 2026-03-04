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
        RootPage()
      }
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
      ]
    }
  }
}
