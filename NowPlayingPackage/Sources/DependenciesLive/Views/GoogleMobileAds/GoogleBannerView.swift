//
//  GoogleBannerView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import GoogleMobileAds
import SwiftUI

public struct GoogleBannerView: UIViewControllerRepresentable {
  // MARK: - Properties
  public let adUnitID: String
  public let height: CGFloat

  public func makeUIViewController(context: Context) -> BannerViewController {
    let viewController = BannerViewController(adUnitID: adUnitID, fixedHeight: height)
    return viewController
  }

  public func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {
  }
}
