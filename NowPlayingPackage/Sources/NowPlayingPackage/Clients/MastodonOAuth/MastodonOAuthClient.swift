//
//  MastodonOAuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Dependencies
import DependenciesMacros
import Foundation
import MastodonKit
import Tagged

@DependencyClient
public struct MastodonOAuthClient: Sendable {
  // MARK: - Tagged
  public typealias AuthorizationCode = Tagged<(Self, authorizationCode: ()), String>

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidCallbackURL
    case internalError
  }

  public var getAuthenticateURL: @Sendable (MastodonClientApplication) throws -> URL
  public var validateCallbackURL: @Sendable (URL) throws -> AuthorizationCode
  public var requestAccessToken: @Sendable (MastodonClientApplication, AuthorizationCode) async throws -> LoginSettings
  public var verifyAccessToken: @Sendable (MastodonClientApplication, LoginSettings) async throws -> MastodonAccount

  fileprivate static let _callbackURLScheme = "nowplaying-ss5dnc-el0eskszufn3qactsets"
}

// MARK: - DependencyKey
extension MastodonOAuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    getAuthenticateURL: { clientApplication in
      var urlComponents = URLComponents(url: clientApplication.domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/oauth/authorize"
      urlComponents.queryItems = [
        .init(name: "response_type", value: "code"),
        .init(name: "client_id", value: clientApplication.clientID.rawValue),
        .init(name: "redirect_uri", value: "\(_callbackURLScheme)://callback/oauth"),
        .init(name: "scope", value: "read+write"),
      ]
      return urlComponents.url!
    },
    validateCallbackURL: { url in
      guard url.scheme == _callbackURLScheme,
            url.host() == "callback",
            url.path() == "/oauth" else {
        throw Error.invalidCallbackURL
      }
      let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
      guard let queryItems = urlComponents?.queryItems,
            let code = queryItems.first(where: { $0.name == "code" })?.value else {
        throw Error.invalidCallbackURL
      }
      return .init(code)
    },
    requestAccessToken: { clientApplication, authorizationCode in
      let client = Client(baseURL: clientApplication.domainURL.absoluteString)
      let request = Login.oauth(
        clientID: clientApplication.clientID.rawValue,
        clientSecret: clientApplication.clientSecret.rawValue,
        scopes: [.read, .write],
        redirectURI: "\(_callbackURLScheme)://callback/oauth",
        code: authorizationCode.rawValue,
      )
      let loginSettings = try await client.response(for: request)

      return loginSettings
    },
    verifyAccessToken: { clientApplication, loginSettings in
      var urlComponents = URLComponents(url: clientApplication.domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/api/v1/accounts/verify_credentials"
      let url = urlComponents.url!
      var urlRequest = URLRequest(url: url)
      urlRequest.addValue("Bearer \(loginSettings.accessToken)", forHTTPHeaderField: "Authorization")
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(MastodonAccount.self, from: data)

      return object
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var mastodonOAuth: MastodonOAuthClient {
    get {
      self[MastodonOAuthClient.self]
    }
    set {
      self[MastodonOAuthClient.self] = newValue
    }
  }
}
