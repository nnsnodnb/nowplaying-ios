//
//  CopyFormatType.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/18.
//

import CasePaths
import Foundation

@CasePathable
public enum CopyFormatType: String, CaseIterable, CustomStringConvertible, Sendable {
  case songTitle = "__songtitle__"
  case artist = "__artist__"
  case album = "__album__"

  // MARK: - Properties
  public var description: String {
    switch self {
    case .songTitle:
      String(localized: .songTitle)
    case .artist:
      String(localized: .artistName)
    case .album:
      String(localized: .albumName)
    }
  }
}
