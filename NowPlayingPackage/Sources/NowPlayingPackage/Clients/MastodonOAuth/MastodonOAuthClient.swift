//
//  MastodonOAuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import CryptoKit
import Dependencies
import DependenciesMacros
import Foundation
import Tagged

@DependencyClient
public struct MastodonOAuthClient: Sendable {
  // MARK: - Tagged
  public typealias CodeVerifier = Tagged<(Self, codeVerifier: ()), String>
  public typealias AuthorizationCode = Tagged<(Self, authorizationCode: ()), String>

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidCallbackURL
    case internalError
    case requireOAuth
  }

  public var getCallbackURLScheme: @Sendable () -> String = { "" }
  public var getAuthenticateURL: @Sendable (MastodonClientApplication) throws -> (URL, CodeVerifier)
  public var validateCallbackURL: @Sendable (URL, CodeVerifier) throws -> AuthorizationCode
  public var requestAccessToken: @Sendable (
    MastodonClientApplication, AuthorizationCode, CodeVerifier
  ) async throws -> MastodonOAuthToken
  public var verifyAccessToken: @Sendable (MastodonClientApplication, MastodonOAuthToken) async throws -> MastodonAccount
  public var getAccessToken: @Sendable (MastodonAccount) async throws -> MastodonOAuthToken.AccessToken

  fileprivate static let _callbackURLScheme = "nowplaying-ss5dnc-el0eskszufn3qactsets"
}

// MARK: - DependencyKey
extension MastodonOAuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    getCallbackURLScheme: {
      Self._callbackURLScheme
    },
    getAuthenticateURL: { clientApplication in
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

      var urlComponents = URLComponents(url: clientApplication.domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/oauth/authorize"
      urlComponents.queryItems = [
        .init(name: "response_type", value: "code"),
        .init(name: "client_id", value: clientApplication.clientID.rawValue),
        .init(name: "redirect_uri", value: "\(_callbackURLScheme)://callback/oauth"),
        .init(name: "scope", value: "read:accounts+write:media+write:statuses"),
        .init(name: "state", value: codeVerifier.rawValue),
        .init(name: "code_challenge", value: codeChallenge),
        .init(name: "code_challenge_method", value: "S256"),
      ]
      return (urlComponents.url!, codeVerifier)
    },
    validateCallbackURL: { url, codeVerifier in
      guard url.scheme == _callbackURLScheme,
            url.host() == "callback",
            url.path() == "/oauth" else {
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
    requestAccessToken: { clientApplication, authorizationCode, codeVerifier in
      var urlComponents = URLComponents(url: clientApplication.domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/oauth/token"
      let url = urlComponents.url!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      let jsonObject: [String: Any] = [
        "grant_type": "authorization_code",
        "code": authorizationCode.rawValue,
        "client_id": clientApplication.clientID.rawValue,
        "client_secret": clientApplication.clientSecret.rawValue,
        "redirect_uri": "\(_callbackURLScheme)://callback/oauth",
        "code_verifier": codeVerifier.rawValue,
      ]
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(MastodonToken.self, from: data)
      let oauthToken = MastodonOAuthToken(
        domainURL: clientApplication.domainURL,
        accessToken: .init(object.accessToken),
        accessTokenType: object.accessTokenType,
        createdAt: object.createdAt,
        scope: object.scope,
      )

      return oauthToken
    },
    verifyAccessToken: { clientApplication, mastodonOAuthToken in
      var urlComponents = URLComponents(url: clientApplication.domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/api/v1/accounts/verify_credentials"
      let url = urlComponents.url!
      var urlRequest = URLRequest(url: url)
      urlRequest.addValue("Bearer \(mastodonOAuthToken.accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(MastodonCredentialAccount.self, from: data)
      let mastodonAccount = MastodonAccount(
        id: .init(object.id),
        domainURL: clientApplication.domainURL,
        displayName: object.displayName,
        username: object.username,
        avatarURL: object.avatarStatic,
      )

      return mastodonAccount
    },
    getAccessToken: { mastodonAccount in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore

      guard let mastodonOAuthToken = try await secureKeyValueStore.getMastodonOAuthToken(mastodonAccount) else {
        throw Error.requireOAuth
      }
      return mastodonOAuthToken.accessToken
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
