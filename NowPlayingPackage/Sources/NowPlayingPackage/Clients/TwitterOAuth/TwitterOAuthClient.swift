//
//  TwitterOAuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import CommonModule
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
      @Dependency(\.functions)
      var functions

      guard let uid = auth.currentUserID() else { throw Error.internalError }
      let endpointURLString = functions.endpointURLString()
      return URL(string: "\(endpointURLString)/twitter_oauth_init?uid=\(uid)")!
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
  )
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
