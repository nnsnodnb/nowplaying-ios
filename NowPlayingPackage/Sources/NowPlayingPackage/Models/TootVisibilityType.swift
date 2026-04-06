//
//  TootVisibilityType.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation

public enum TootVisibilityType: String, CaseIterable, Sendable {
  case `public`
  case unlisted
  case `private`

  // MARK: - Properties
  public var displayName: String {
    switch self {
    case .public:
      String(localized: .tootPublic)
    case .unlisted:
      String(localized: .tootUnlisted)
    case .private:
      String(localized: .tootPrivate)
    }
  }
}
