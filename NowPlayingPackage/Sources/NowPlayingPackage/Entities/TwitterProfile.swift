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

  // MARK: - Initialize
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(TwitterProfile.ID.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.username = try container.decode(String.self, forKey: .username)
    var profileImageURLString = try container.decode(String.self, forKey: .profileImageURL)
    if profileImageURLString.hasSuffix("_normal.jpg") {
      profileImageURLString = profileImageURLString.replacingOccurrences(of: "_normal.jpg", with: ".jpg")
    }
    self.profileImageURL = URL(string: profileImageURLString)!
  }
}
