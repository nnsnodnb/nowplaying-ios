//
//  StubMediaItem.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import Foundation
import MemberwiseInit
@testable import NowPlayingPackage

@MemberwiseInit
struct StubMediaItem: MediaItemProtocol {
  // MARK: - Properties
  @Init(default: "stub_title")
  let title: String?
  @Init(default: "stub_artist")
  let artist: String?
  @Init(default: "stub_album_title")
  let albumTitle: String?
  @Init(default: nil)
  let artworkImage: UIImage?
}
