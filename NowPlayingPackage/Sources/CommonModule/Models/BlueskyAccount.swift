//
//  BlueskyAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import Foundation
import MemberwiseInit
import OAuthenticator
import Tagged

@MemberwiseInit(.public)
public struct BlueskyAccount: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias DID = Tagged<(Self, did: ()), String>
  public typealias Password = Tagged<(Self, password: ()), String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id = "did"
    case handle
    case displayName
    case avatarImageURL = "avatar"
    case isDefault
  }

  // MARK: - Properties
  @Init(.public)
  public let id: DID
  @Init(.public)
  public let handle: String
  @Init(.public)
  public let displayName: String?
  @Init(.public)
  public let avatarImageURL: URL?
  @Init(.public, default: false)
  public private(set) var isDefault: Bool

  public mutating func setDefault(_ isDefault: Bool = true) {
    self.isDefault = isDefault
  }

  // MARK: - Initialize
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(DID.self, forKey: .id)
    self.handle = try container.decode(String.self, forKey: .handle)
    self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
    self.avatarImageURL = try container.decodeIfPresent(URL.self, forKey: .avatarImageURL)
    self.isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
  }
}

// MARK: - Identity
public extension BlueskyAccount {
  @MemberwiseInit(.public)
  struct Identity: Codable, Sendable {
    // MARK: - Properties
    public let did: BlueskyAccount.DID
    public let pds: URL
    public let serverMetadata: ServerMetadata
  }
}

// MARK: - Typealias
public extension BlueskyAccount {
  typealias Login = OAuthenticator::Login
}
