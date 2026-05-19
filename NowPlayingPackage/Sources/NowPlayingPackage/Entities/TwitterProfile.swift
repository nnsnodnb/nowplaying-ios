//
//  TwitterProfile.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import Foundation
import MemberwiseInit
import Tagged

@MemberwiseInit(.public)
public struct TwitterProfile: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<Self, String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case username
    case profileImageURL = "profile_image_url"
  }

  // MARK: - Properties
  public let id: ID
  public let name: String
  public let username: String
  public let profileImageURL: URL
}
