//
//  MastodonCredentialApplication.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation

public struct MastodonCredentialApplication: Decodable, Sendable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case redirectURI = "redirect_uri"
    case clientID = "client_id"
    case clientSecret = "client_secret"
  }

  // MARK: - Properties
  public let id: MastodonClientApplication.ID
  public let redirectURI: String
  public let clientID: MastodonClientApplication.ClientID
  public let clientSecret: MastodonClientApplication.ClientSecret
}
