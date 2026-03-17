//
//  TwitterOAuthToken.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import Dependencies
import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct TwitterOAuthToken: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias AccessToken = Tagged<(Self, accessToken: ()), String>
  public typealias RefreshToken = Tagged<(Self, refreshToken: ()), String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case expiresIn = "expires_in"
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case scope
    case expiresAt
  }

  // MARK: - Properties
  public let expiresIn: Int
  public let accessToken: AccessToken
  public let refreshToken: RefreshToken
  public let scope: String

  public var isExpired: Bool {
    @Dependency(\.date)
    var date

    return expiresAt <= date.now
  }

  @Init(.public)
  private let expiresAt: Date

  // MARK: - Initialize
  public init(from decoder: any Decoder) throws {
    @Dependency(\.date)
    var date

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
    self.accessToken = try container.decode(AccessToken.self, forKey: .accessToken)
    self.refreshToken = try container.decode(RefreshToken.self, forKey: .refreshToken)
    self.scope = try container.decode(String.self, forKey: .scope)
    if let expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt) {
      self.expiresAt = expiredAt
    } else {
      self.expiresAt = date.now.addingTimeInterval(TimeInterval(expiresIn - 10))
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.expiresIn, forKey: .expiresIn)
    try container.encode(self.accessToken, forKey: .accessToken)
    try container.encode(self.refreshToken, forKey: .refreshToken)
    try container.encode(self.scope, forKey: .scope)
    try container.encode(self.expiresAt, forKey: .expiresAt)
  }
}
