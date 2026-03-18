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
      "アートワークのみ"
    case .screenShot:
      "再生画面のスクリーンショット"
    }
  }
}
