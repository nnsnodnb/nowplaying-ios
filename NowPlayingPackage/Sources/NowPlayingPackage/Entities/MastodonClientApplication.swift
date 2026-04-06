//
//  MastodonClientApplication.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation
import Tagged

public struct MastodonClientApplication: Codable, Equatable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias ClientID = Tagged<(Self, clientID: ()), String>
  public typealias ClientSecret = Tagged<(Self, clientSecret: ()), String>

  // MARK: - Properties
  public let id: ID
  public let domainURL: URL
  public let redirectURI: String
  public let clientID: ClientID
  public let clientSecret: ClientSecret
}
