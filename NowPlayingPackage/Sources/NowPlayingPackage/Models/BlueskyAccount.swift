//
//  BlueskyAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct BlueskyAccount: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias DID = Tagged<Self, String>

  // MARK: - Properties
  public let id: DID
  public let handle: String
  public let displayName: String?
  public let avatarImageURL: URL?
  public let password: String
  @Init(.public)
  public private(set) var isDefault = false

  public mutating func setDefault(_ isDefault: Bool = true) {
    self.isDefault = isDefault
  }
}
