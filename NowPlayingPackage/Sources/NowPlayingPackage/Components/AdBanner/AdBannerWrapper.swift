//
//  AdBannerWrapper.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import GoogleMobileAds
import SwiftUI

struct AdBannerWrapper: UIViewRepresentable {
  // MARK: - Properties
  let adSize: AdSize
  let adUnitID: String

  func makeUIView(context: Context) -> BannerView {
    let banner = BannerView(adSize: adSize)
    banner.adUnitID = adUnitID
    banner.load(Request())
    banner.delegate = context.coordinator
    return banner
  }

  func updateUIView(_ uiView: BannerView, context: Context) {
  }

  func makeCoordinator() -> Coordinator {
    .init(parent: self)
  }
}

// MARK: - Coordinator
extension AdBannerWrapper {
  final class Coordinator: NSObject, BannerViewDelegate {
    // MARK: - Properties
    private let parent: AdBannerWrapper

    // MARK: - Initialize
    init(parent: AdBannerWrapper) {
      self.parent = parent
    }
  }
}

#Preview {
  AdBannerWrapper(
    adSize: AdSizeBanner,
    adUnitID: "ca-app-pub-3940256099942544/2435281174",
  )
}
