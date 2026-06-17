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

public extension TwitterProfile {
  static let nnsnodnb: Self = .init(
    id: .init("1137201750"),
    name: "小泉ひやかし🌻",
    username: "nnsnodnb",
    profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq_normal.jpg")!,
  )
}
