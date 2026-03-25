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
              $0.twitterAPI.getUserMe = { _ in
                // swiftlint:disable line_length
                TwitterProfile(
                  id: .init("1137201750"),
                  name: "小泉ひやかし🌻",
                  username: "nnsnodnb",
                  profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq_normal.jpg")!,
                  /*
                  id: .init("3252831121"),
                  name: "Yuya KOIZUMI",
                  username: "FavKisei",
                  profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1701714208818372608/M3zFaf6C_normal.jpg")!,
                   */
                )
                // swiftlint:enable line_length
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
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
      ]
    }
    Purchases.configure(withAPIKey: "appl_bFpdFCHLAyHiwuozSKJgbMNPZkD")
    Task {
      _ = try await Purchases.shared.logIn("$RCAnonymousID:9d6c93f9b9c0446c8c07fdc0a281b476")
    }
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
