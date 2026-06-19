//
//  PlayerBottomAdBanner.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import Dependencies
import DependenciesInterfaces
import SwiftUI

public struct PlayerBottomAdBanner: View {
  // MARK: - Properties
  let adUnitID: String

  @Dependency(\.adClient)
  private var adClient

  // MARK: - Body
  public var body: some View {
    GeometryReader { proxy in
      adClient.make(
        adUnitID: adUnitID,
        size: .banner,
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
