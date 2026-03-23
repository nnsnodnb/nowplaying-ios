//
//  BlueskyOAuthToken.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import Foundation
import Tagged

public struct BlueskyOAuthToken {
  // MARK: - Tagged
  public typealias AccessToken = Tagged<(Self, accessToken: ()), String>
}
