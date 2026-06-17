//
//  ResponseInfoProtocol.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import Foundation

public protocol ResponseInfoProtocol {
  var responseIdentifier: String? { get }
  var adNetworkInfo: [any AdNetworkResponseInfoProtocol] { get }
}
