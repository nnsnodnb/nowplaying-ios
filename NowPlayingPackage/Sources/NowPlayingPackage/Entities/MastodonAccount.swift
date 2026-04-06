//
//  MastodonAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation
import Tagged

public struct MastodonAccount: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<Self, String>

  // MARK: - Properties
  public let id: ID
  public let domainURL: URL
  public let displayName: String
  public let username: String
  public let avatarURL: URL
  public private(set) var isDefault = false

  public mutating func setDefault(_ isDefault: Bool = true) {
    self.isDefault = isDefault
  }
}
