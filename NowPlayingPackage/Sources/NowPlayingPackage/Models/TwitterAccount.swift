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
  // MARK: - Tagged
  public typealias RefreshToken = Tagged<(Self, refreshToken: ()), String>
  public typealias AccessToken = Tagged<(Self, accessToken: ()), String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh_token"
    case accessToken = "access_token"
    case expiresIn = "expires_in"
    case expiredAt
  }

  // MARK: - Properties
  public let refreshToken: RefreshToken
  public let accessToken: AccessToken
  public let expiredAt: Date

  private let expiresIn: Int

  // MARK: - Initialize
  public init(from decoder: any Decoder) throws {
    @Dependency(\.date)
    var date

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.refreshToken = try container.decode(RefreshToken.self, forKey: .refreshToken)
    self.accessToken = try container.decode(AccessToken.self, forKey: .accessToken)
    self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
    self.expiredAt = date.now.addingTimeInterval(TimeInterval(expiresIn - 10))
  }

  // MARK: - Encodable
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(refreshToken, forKey: .refreshToken)
    try container.encode(accessToken, forKey: .accessToken)
    try container.encode(expiredAt, forKey: .expiredAt)
  }
}
