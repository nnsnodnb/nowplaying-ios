//
//  GoogleBannerView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import CommonModule
import Dependencies
import GoogleMobileAds
import SwiftUI

public struct GoogleBannerView: UIViewRepresentable {
  public let adUnitID: String
  public let size: BannerSize

  public func makeUIView(context: Context) -> some UIView {
    let banner = BannerView()
    banner.adUnitID = adUnitID
    banner.adSize = switch size {
    case .banner:
      AdSizeBanner
    case .largeBanner:
      AdSizeLargeBanner
    case .mediumRectangle:
      AdSizeMediumRectangle
    }

    banner.load(Request())
    banner.delegate = context.coordinator

    return banner
  }

  public func updateUIView(_ uiView: UIViewType, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    .init(parent: self)
  }
}

// MARK: - Coordinator
public extension GoogleBannerView {
  final class Coordinator: NSObject, BannerViewDelegate {
    // MARK: - Properties
    private let parent: GoogleBannerView

    // MARK: - Dependency
    @Dependency(\.crashlytics)
    private var crashlytics

    // MARK: - Initialize
    init(parent: GoogleBannerView) {
      self.parent = parent
    }

    // MARK: - BannerViewDelegate
    public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
      try? crashlytics.recordAdBannerLoadError(bannerView.responseInfo, error)
    }
  }
}
