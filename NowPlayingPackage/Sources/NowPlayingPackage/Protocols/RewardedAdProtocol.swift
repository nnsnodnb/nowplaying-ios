//
//  RewardedAdProtocol.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Foundation
import GoogleMobileAds

public protocol RewardedAdProtocol: Equatable, Sendable {
  var adUnitID: String { get }

  @MainActor
  func canPresent() throws
  @MainActor
  func present(delegate: (any FullScreenContentDelegate)?, userDidEarnRewardHandler: @escaping () -> Void)
}
