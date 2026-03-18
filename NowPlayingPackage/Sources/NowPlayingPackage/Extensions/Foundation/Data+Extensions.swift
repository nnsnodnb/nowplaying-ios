//
//  Data+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import Foundation

public extension Data {
  func base64URLSafeEncodedString() -> String {
    let encoded = base64EncodedString()
    let urlSafe = encoded
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")

    return urlSafe
  }

  mutating func append(_ string: String) {
    append(Data(string.utf8))
  }
}
