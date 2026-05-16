//
//  Migration.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import Foundation

public struct Migration {}

// MARK: - V320
extension Migration {
  public struct V320 {
    // MARK: - Properties
    public let twitterAccount: TwitterAccount
    public let refreshToken: TwitterOAuthToken.RefreshToken
  }
}
