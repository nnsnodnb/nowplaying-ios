//
//  MastodonMediaAttachment.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import Foundation
import Tagged

public struct MastodonMediaAttachment: Decodable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<Self, String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case url
    case previewURL = "preview_url"
  }

  // MARK: - Properties
  public let id: ID
  public let url: URL
  public let previewURL: URL
}
