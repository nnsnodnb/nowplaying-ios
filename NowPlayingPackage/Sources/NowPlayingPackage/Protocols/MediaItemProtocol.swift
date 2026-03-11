//
//  MediaItemProtocol.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import UIKit

public protocol MediaItemProtocol: Sendable {
  var title: String? { get }
  var artist: String? { get }
  var albumTitle: String? { get }
  var artworkImage: UIImage? { get }
}
