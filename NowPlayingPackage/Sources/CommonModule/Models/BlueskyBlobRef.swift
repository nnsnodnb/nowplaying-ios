//
//  BlueskyBlobRef.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/17.
//

import Foundation

public struct BlueskyBlobRef: Codable, Sendable {
  // MARK: - Link
  public struct Link: Codable, Sendable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case link = "$link"
    }

    // MARK: - Properties
    public let link: String
  }

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case type = "$type"
    case ref
    case mimeType
    case size
  }

  // MARK: - Properties
  public let type: String
  public let ref: Link
  public let mimeType: String
  public let size: Int
}
