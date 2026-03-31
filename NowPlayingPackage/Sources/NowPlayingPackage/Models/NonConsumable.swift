//
//  NonConsumable.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import Foundation

public enum NonConsumable: String, Codable, CustomStringConvertible, Sendable {
  case hideAds = "moe.nnsnodnb.NowPlaying.hideAdMob"
  case autoTweet = "moe.nnsnodnb.NowPlaying.autoTweet"

  // MARK: - CustomStringConvertible
  public var description: String {
    switch self {
    case .hideAds:
      String(localized: .removeBannerAds)
    case .autoTweet:
      String(localized: .automaticPostingForX)
    }
  }
}
