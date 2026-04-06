//
//  MastodonToken.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation

public struct MastodonToken: Decodable, Sendable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case accessTokenType = "token_type"
    case scope
    case createdAt = "created_at"
  }

  // MARK: - Properties
  public let accessToken: String
  public let accessTokenType: String
  public let createdAt: TimeInterval
  public let scope: String
}
