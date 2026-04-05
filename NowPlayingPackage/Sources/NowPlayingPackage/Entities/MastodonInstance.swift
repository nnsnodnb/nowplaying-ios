//
//  MastodonInstance.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import Foundation

public struct MastodonInstance: Decodable, Equatable, Sendable {
  // MARK: - Properties
  public let domain: String
  public let title: String
  public let thumbnail: Thumbnail
}

// MARK: - Thumbnail
public extension MastodonInstance {
  struct Thumbnail: Decodable, Equatable, Sendable {
    // MARK: - Properties
    public let url: URL
  }
}
