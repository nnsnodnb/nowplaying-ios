//
//  AdUnitClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AdUnitClient: Sendable {
  public var playerBottomBannerAdUnitID: @Sendable () -> String = { "ca-app-pub-3940256099942544/2435281174" }
  public var addTwitterAccountRewardAdUnitID: @Sendable () -> String = { "ca-app-pub-3940256099942544/1712485313" }
  public var getFreePostTicketRewardAdUnitID: @Sendable () -> String = { "ca-app-pub-3940256099942544/1712485313" }
}

// MARK: - DependencyKey
extension AdUnitClient: DependencyKey {
  public static let liveValue: Self = .init(
    playerBottomBannerAdUnitID: { "ca-app-pub-3940256099942544/2435281174" },
    addTwitterAccountRewardAdUnitID: { "ca-app-pub-3940256099942544/1712485313" },
    getFreePostTicketRewardAdUnitID: { "ca-app-pub-3940256099942544/1712485313" },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var adUnit: AdUnitClient {
    get {
      self[AdUnitClient.self]
    }
    set {
      self[AdUnitClient.self] = newValue
    }
  }
}
