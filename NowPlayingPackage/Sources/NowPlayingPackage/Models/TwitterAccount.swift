//
//  TwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Dependencies
import Foundation
import Tagged

public struct TwitterAccount: Codable, Hashable, Sendable {
  // MARK: - Properties
  public let profile: TwitterProfile
  public private(set) var isDefault = false

  public mutating func setDefault(_ isDefault: Bool = true) {
    self.isDefault = isDefault
  }
}
