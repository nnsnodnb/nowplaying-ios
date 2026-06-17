//
//  TwitterMedia.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Dependencies
import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct TwitterMedia: Equatable, Decodable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<Self, String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case expiresAfterSecs = "expires_after_secs"
    case expiresAt
  }

  // MARK: - Properties
  public let id: ID
  public let expiresAfterSecs: Int

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
    self.id = try container.decode(TwitterMedia.ID.self, forKey: .id)
    self.expiresAfterSecs = try container.decode(Int.self, forKey: .expiresAfterSecs)
    self.expiresAt = date.now.addingTimeInterval(TimeInterval(expiresAfterSecs - 5))
  }
}
