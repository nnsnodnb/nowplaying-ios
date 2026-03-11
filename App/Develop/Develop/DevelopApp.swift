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
                TwitterProfile(
                  id: .init("1137201750"),
                  name: "小泉ひやかし🌻",
                  username: "nnsnodnb",
                  // swiftlint:disable:next line_length
                  profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq_normal.jpg")!,
                  /*
                  id: .init("3252831121"),
                  name: "Yuya KOIZUMI",
                  username: "FavKisei",
                  // swiftlint:disable:next line_length
                  profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1701714208818372608/M3zFaf6C_normal.jpg")!,
                   */
                )
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
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
