//
//  MastodonAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation
import Tagged

public struct MastodonAccount: Codable, Equatable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<Self, String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case displayName = "display_name"
    case username
    case avatarStatic = "avatar_static"
  }

  // MARK: - Properties
  public let id: ID
  public let displayName: String
  public let username: String
  public let avatarStatic: URL
}
