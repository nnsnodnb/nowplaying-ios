//
//  MastodonOAuthToken.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation
import Tagged

public struct MastodonOAuthToken: Codable, Equatable, Sendable {
  // MARK: - Tagged
  public typealias AccessToken = Tagged<Self, String>

  // MARK: - Properties
  public let domainURL: URL
  public let accessToken: AccessToken
  public let accessTokenType: String
  public let createdAt: TimeInterval
  public let scope: String
}
