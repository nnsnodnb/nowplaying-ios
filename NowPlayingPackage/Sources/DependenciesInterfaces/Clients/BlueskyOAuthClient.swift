//
//  BlueskyOAuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/15.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation
import OAuthenticator

@DependencyClient
public struct BlueskyOAuthClient: Sendable {
  public var resolveIdentity: @Sendable (_ handle: String) async throws -> BlueskyAccount.Identity
  public var makeAuthenticator: @Sendable (
    _ handle: String, _ identity: BlueskyAccount.Identity, _ key: Data
  ) async throws -> any AuthenticatorProtocol
}

// MARK: - DependencyKey
extension BlueskyOAuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    resolveIdentity: { _ in
      .init(
        did: .init("stub_did"),
        pds: URL(string: "https://example.com")!,
        serverMetadata: try await ServerMetadata.load(
          for: "https://bsky.social/.well-known/oauth-authorization-server",
          provider: URLSession.defaultProvider,
        ),
      )
    },
    makeAuthenticator: { _, _, _ in
      MockAuthenticator()
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var blueskyOAuth: BlueskyOAuthClient {
    get {
      self[BlueskyOAuthClient.self]
    }
    set {
      self[BlueskyOAuthClient.self] = newValue
    }
  }
}

// MARK: - MockAuthenticator
public extension BlueskyOAuthClient {
  actor MockAuthenticator: AuthenticatorProtocol {
    // MARK: - Error
    enum Error: Swift::Error {
      case notImplemented
    }

    public func authenticate(with userAuthenticator: Authenticator.UserAuthenticator?) async throws -> Login {
      throw Error.notImplemented
    }

    public func response(for request: URLRequest) async throws -> (Data, URLResponse) {
      throw Error.notImplemented
    }
  }
}
