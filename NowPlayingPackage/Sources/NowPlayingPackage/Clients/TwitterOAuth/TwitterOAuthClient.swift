//
//  TwitterOAuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import CryptoKit
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct TwitterOAuthClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidCallbackURL
    case requiredOAuth
    case internalError
  }

  public var getCallbackURLScheme: @Sendable () -> String = { "" }
  public var getAuthenticateURL: @Sendable () throws -> URL
  public var validateCallbackURL: @Sendable (URL) throws -> TwitterProfile.ID
  // TODO: 削除
  public var getAccessToken: @Sendable (TwitterAccount) async throws -> TwitterOAuthToken.AccessToken

  fileprivate static let _callbackURLScheme = "nowplaying-ss5dnc-el0eskszufn3qactsets"
  fileprivate static let _clientID = "cFkwa24zTlhGck1KUkViZENOUHc6MTpjaQ"
}

// MARK: - DependencyKey
extension TwitterOAuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    getCallbackURLScheme: {
      Self._callbackURLScheme
    },
    getAuthenticateURL: {
      @Dependency(\.auth)
      var auth

      guard let uid = auth.currentUserID() else { throw Error.internalError }
      return URL(string: "https://asia-northeast1-nowplayingios.cloudfunctions.net/twitter_oauth_init?uid=\(uid)")!
    },
    validateCallbackURL: { url in
      guard url.scheme == Self._callbackURLScheme,
            url.host == "callback",
            url.path() == "/oauth",
            let query = url.query(percentEncoded: false) else {
        throw Error.invalidCallbackURL
      }
      let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
      guard let queryItems = urlComponents?.queryItems,
            let userID = queryItems.first(where: { $0.name == "user_id" })?.value else {
        throw Error.invalidCallbackURL
      }
      return .init(userID)
    },
    getAccessToken: { account in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore

      guard let oauthToken = try await secureKeyValueStore.getTwitterOAuthToken(account) else {
        throw Error.requiredOAuth
      }
      let accessToken: TwitterOAuthToken.AccessToken
      if oauthToken.isExpired {
        let oauthToken = try await Self.refreshAccessToken(for: account, refreshToken: oauthToken.refreshToken)
        return oauthToken.accessToken
      } else {
        return oauthToken.accessToken
      }
    },
  )

  // TODO: 削除
  private static func refreshAccessToken(
    for account: TwitterAccount,
    refreshToken: TwitterOAuthToken.RefreshToken,
  ) async throws -> TwitterOAuthToken {
    var urlComponents = URLComponents(string: "https://api.x.com")!
    urlComponents.path = "/2/oauth2/token"
    guard let url = urlComponents.url else {
      throw Error.invalidCallbackURL
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let params: [String: String] = [
      "grant_type": "refresh_token",
      "client_id": Self._clientID,
      "refresh_token": refreshToken.rawValue,
    ]
    var paramURLComponents = URLComponents()
    paramURLComponents.queryItems = params.map { .init(name: $0, value: $1) }
    urlRequest.httpBody = paramURLComponents.percentEncodedQuery?.data(using: .utf8)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
      throw Error.internalError
    }
    let jsonDecoder = JSONDecoder()
    let oauthToken = try jsonDecoder.decode(TwitterOAuthToken.self, from: data)

    // oauthTokenの置き換え
    @Dependency(\.secureKeyValueStore)
    var secureKeyValueStore

    try await secureKeyValueStore.setTwitterOAuthToken(account, oauthToken)

    return oauthToken
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var twitterOAuth: TwitterOAuthClient {
    get {
      self[TwitterOAuthClient.self]
    }
    set {
      self[TwitterOAuthClient.self] = newValue
    }
  }
}
