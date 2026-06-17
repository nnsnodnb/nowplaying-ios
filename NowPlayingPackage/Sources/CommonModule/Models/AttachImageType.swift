//
//  AttachImageType.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/18.
//

import Foundation

public enum AttachImageType: String, CaseIterable, Sendable {
  case onlyArtwork
  case screenShot

  // MARK: - Properties
  public var displayName: String {
    switch self {
    case .onlyArtwork:
      String(localized: .artworkOnly)
    case .screenShot:
      String(localized: .screenshotOfThePlaybackScreen)
    }
  }
}
