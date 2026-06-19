//
//  TwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct TwitterAccount: Codable, Hashable, Sendable {
  // MARK: - Properties
  public let profile: TwitterProfile
  @Init(.public, default: false)
  public private(set) var isDefault: Bool

  public mutating func setDefault(_ isDefault: Bool = true) {
    self.isDefault = isDefault
  }
}
