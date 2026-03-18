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
import Tagged

@DependencyClient
public struct TwitterOAuthClient: Sendable {
  // MARK: - Tagged
  public typealias CodeVerifier = Tagged<(Self, codeVerifier: ()), String>
  public typealias AuthorizationCode = Tagged<(Self, authorizationCode: ()), String>

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidCallbackURL
    case internalError
  }

  public var getCallbackURLScheme: @Sendable () -> String = { "" }
  public var getAuthenticateURL: @Sendable () throws -> (URL, CodeVerifier)
  public var validateCallbackURL: @Sendable (URL, CodeVerifier) throws -> AuthorizationCode
  public var requestAccessToken: @Sendable (CodeVerifier, AuthorizationCode) async throws -> TwitterOAuthToken
  public var getAccessToken: @Sendable (TwitterOAuthToken) async throws -> TwitterOAuthToken.AccessToken

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
      let codeVerifier: CodeVerifier = {
        var data = Data(count: 48)
        let result = data.withUnsafeMutableBytes { bytes in
          SecRandomCopyBytes(kSecRandomDefault, 48, bytes.baseAddress!)
        }
        precondition(result == errSecSuccess)
        let base64Encoded = data.base64URLSafeEncodedString()
        return .init(base64Encoded)
      }()
      let codeChallenge: String = {
        let digest = SHA256.hash(data: Data(codeVerifier.utf8))
        let data = Data(digest)
        let base64Encoded = data.base64URLSafeEncodedString()
        return base64Encoded
      }()

      var urlComponents = URLComponents(string: "https://x.com")!
      urlComponents.path = "/i/oauth2/authorize"
      urlComponents.queryItems = [
        .init(name: "response_type", value: "code"),
        .init(name: "client_id", value: Self._clientID),
        .init(name: "redirect_uri", value: "\(Self._callbackURLScheme)://callback/oauth"),
        .init(name: "scope", value: "users.read tweet.read tweet.write media.write offline.access"),
        .init(name: "state", value: codeVerifier.rawValue),
        .init(name: "code_challenge", value: codeChallenge),
        .init(name: "code_challenge_method", value: "S256"),
      ]
      return (urlComponents.url!, codeVerifier)
    },
    validateCallbackURL: { url, codeVerifier in
      guard url.scheme == Self._callbackURLScheme,
            url.host == "callback",
            url.path == "/oauth",
            let query = url.query(percentEncoded: false) else {
        throw Error.invalidCallbackURL
      }
      let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
      guard let queryItems = urlComponents?.queryItems,
            queryItems.first(where: { $0.name == "state" })?.value == codeVerifier.rawValue,
            let code = queryItems.first(where: { $0.name == "code" })?.value else {
        throw Error.invalidCallbackURL
      }
      return .init(code)
    },
    requestAccessToken: { codeVerifier, code in
      let url = URL(string: "https://api.x.com/2/oauth2/token")!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      let params: [String: String] = [
        "code": code.rawValue,
        "grant_type": "authorization_code",
        "client_id": Self._clientID,
        "redirect_uri": "\(Self._callbackURLScheme)://callback/oauth",
        "code_verifier": codeVerifier.rawValue,
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

      return oauthToken
    },
    getAccessToken: { oauthToken in
      let accessToken: TwitterOAuthToken.AccessToken
      if oauthToken.isExpired {
        let oauthToken = try await Self.refreshAccessToken(oauthToken.refreshToken)
        return oauthToken.accessToken
      } else {
        return oauthToken.accessToken
      }
    },
  )

  private static func refreshAccessToken(_ refreshToken: TwitterOAuthToken.RefreshToken) async throws -> TwitterOAuthToken {
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

    var twitterAccounts = try await secureKeyValueStore.twitterAccounts()
    if let index = twitterAccounts.firstIndex(where: { $0.oauthToken.refreshToken == refreshToken }),
       let twitterAccount = twitterAccounts[safe: index] {
      twitterAccounts[index] = .init(
        oauthToken: oauthToken,
        profile: twitterAccount.profile,
        isDefault: twitterAccount.isDefault,
      )
      try await secureKeyValueStore.setTwitterAccounts(twitterAccounts)
    }

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
