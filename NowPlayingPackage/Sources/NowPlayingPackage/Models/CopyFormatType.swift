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
      "曲名"
    case .artist:
      "歌手名"
    case .album:
      "アルバム名"
    }
  }
}
