//
//  String+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/16.
//

import Foundation

extension String {
  func base64URLDecodedString() -> Data? {
    var base64 = self
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let paddingCount = 4 - (base64.count % 4)
    let padding = String(repeating: "=", count: paddingCount)
    base64.append(padding)
    return Data(base64URLEncoded: base64)
  }
}
