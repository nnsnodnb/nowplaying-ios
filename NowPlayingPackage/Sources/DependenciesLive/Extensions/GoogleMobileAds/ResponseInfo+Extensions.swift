//
//  ResponseInfo+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import Foundation
import GoogleMobileAds

// MARK: - ResponseInfoProtocol
extension ResponseInfo: ResponseInfoProtocol {
  public var adNetworkInfo: [any AdNetworkResponseInfoProtocol] {
    adNetworkInfoArray
  }
}
