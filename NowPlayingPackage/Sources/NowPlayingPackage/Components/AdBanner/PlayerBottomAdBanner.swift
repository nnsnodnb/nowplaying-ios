//
//  PlayerBottomAdBanner.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import SwiftUI

public struct PlayerBottomAdBanner: View {
  // MARK: - Properties
  let adUnitID: String

  // MARK: - Body
  public var body: some View {
    GeometryReader { proxy in
      AdBannerWrapper(
        adSize: AdSizeBanner,
        adUnitID: adUnitID,
      )
      .frame(width: proxy.size.width, height: 60)
    }
    .frame(height: 60)
  }
}

#Preview {
  PlayerBottomAdBanner(
    adUnitID: "ca-app-pub-3940256099942544/2435281174",
  )
}
