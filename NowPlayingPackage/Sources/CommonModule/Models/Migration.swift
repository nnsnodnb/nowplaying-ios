//
//  Migration.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import Foundation
import MemberwiseInit

public struct Migration {}

// MARK: - V320
public extension Migration {
  @MemberwiseInit(.public)
  struct V320 {
    // MARK: - Properties
    public let twitterAccount: TwitterAccount
    public let refreshToken: TwitterOAuthToken.RefreshToken
  }
}
