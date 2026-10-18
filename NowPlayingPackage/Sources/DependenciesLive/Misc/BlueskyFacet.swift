//
//  BlueskyFacet.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/18.
//

import Foundation

struct BlueskyFacet: Encodable {
  // MARK: - Properties
  let index: Index
  let features: [Feature]
}

// MARK: - Index
extension BlueskyFacet {
  struct Index: Encodable {
    // MARK: - Properties
    let byteStart: Int
    let byteEnd: Int
  }
}

// MARK: - Feature
extension BlueskyFacet {
  struct Feature: Encodable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case type = "$type"
      case tag
    }

    // MARK: - Properties
    let type = "app.bsky.richtext.facet#tag"
    let tag: String
  }
}
