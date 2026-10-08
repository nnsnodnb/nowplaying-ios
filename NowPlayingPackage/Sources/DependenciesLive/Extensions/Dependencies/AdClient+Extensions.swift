//
//  AdClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import SwiftUI

public extension AdClient {
  static let google: Self = .init(
    make: { adUnitID, height in
      AnyView(
        GoogleBannerView(adUnitID: adUnitID, height: height)
      )
    },
  )
}
