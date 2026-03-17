//
//  RewardedAd+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Foundation
import GoogleMobileAds

// MARK: - RewardedAdProtocol
extension RewardedAd: RewardedAdProtocol {
  public func canPresent() throws {
    try canPresent(from: nil)
  }

  public func present(delegate: (any FullScreenContentDelegate)?, userDidEarnRewardHandler: @escaping () -> Void) {
    fullScreenContentDelegate = delegate
    present(from: nil, userDidEarnRewardHandler: userDidEarnRewardHandler)
  }
}
