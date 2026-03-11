//
//  Array+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import Foundation

public extension Array {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
