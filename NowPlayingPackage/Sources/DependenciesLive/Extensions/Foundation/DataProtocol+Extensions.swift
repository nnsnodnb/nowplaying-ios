//
//  DataProtocol+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/15.
//

import Foundation

extension DataProtocol {
  func base64URLEncodedString() -> String {
    Data(self)
      .base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
