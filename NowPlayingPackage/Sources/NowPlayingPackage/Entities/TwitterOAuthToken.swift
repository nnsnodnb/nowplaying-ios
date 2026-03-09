//
//  TwitterOAuthToken.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import Dependencies
import Foundation
import Tagged

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
    self.expiresAt = date.now.addingTimeInterval(TimeInterval(expiresIn - 10))
  }
}
