//
//  MPMediaItem+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import Foundation
import MediaPlayer

// MARK: - MediaItemProtocol
extension MPMediaItem: MediaItemProtocol {
  public var artworkImage: UIImage? {
    guard let artwork else { return nil }
    return artwork.image(at: artwork.bounds.size)
  }
}
