//
//  TwitterAccount.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Foundation
import Tagged

public struct TwitterAccount: Codable, Hashable, Sendable {
  // MARK: - Tagged
  public typealias RefreshToken = Tagged<(Self, refreshToken: ()), String>
  public typealias AccessToken = Tagged<(Self, accessToken: ()), String>

  // MARK: - Properties
  public let refreshToken: RefreshToken
  public let accessToken: AccessToken
}
