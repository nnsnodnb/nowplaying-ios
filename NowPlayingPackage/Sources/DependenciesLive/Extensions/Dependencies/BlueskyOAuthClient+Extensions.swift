//
//  BlueskyOAuthClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/15.
//

import ATIdentityTools
import AuthenticationServices
import CommonModule
import CryptoKit
import Dependencies
import DependenciesInterfaces
import Foundation
import OAuthenticator

// MARK: - Error
public extension BlueskyOAuthClient {
  enum Error: Swift::Error {
    case noAuthServer
    case invalidServerMetadata
    case dPoPInvalidProof
    case oauthError
  }
}

public extension BlueskyOAuthClient {
  static let oAuthenticator: Self = .init(
    resolveIdentity: { handle in
      let jsonDecoder = JSONDecoder()

      var resolver = IdentityResolver(
        handleOptions: .init(timeout: 10),
        didOptions: .init(timeout: 10, didCache: MemoryCache()),
      )

      let resolvedIdentity = try await resolver.resolveVerifiedIdentity(handle: handle)
      let resourceURL = resolvedIdentity.pds.appending(path: "/.well-known/oauth-protected-resource")
      let (data, _) = try await URLSession.shared.data(from: resourceURL)
      let resource = try jsonDecoder.decode(ResourceResponse.self, from: data)
      guard let issuer = resource.authorizationServers.first else {
        throw Error.noAuthServer
      }

      let serverMetadata: ServerMetadata = try await {
        var urlRequst = URLRequest(url: issuer.appending(path: "/.well-known/oauth-authorization-server"))
        urlRequst.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: urlRequst)
        let serverMetadata = try jsonDecoder.decode(ServerMetadata.self, from: data)

        return serverMetadata
      }()

      let identity = BlueskyAccount.Identity(
        did: .init(resolvedIdentity.did),
        pds: resolvedIdentity.pds,
        serverMetadata: serverMetadata,
      )
      return identity
    },
    makeAuthenticator: { handle, identity, key in
      try await Implementation.shared.makeAuthenticator(
        handle: handle,
        did: identity.did,
        server: identity.serverMetadata,
        key: key,
      )
    },
  )
}

// MARK: - DPoP
private extension BlueskyOAuthClient {
  enum DPoP {
    static func generate(key: Data) -> DPoPSigner.JWTGenerator {
      return { parameters in
        @Dependency(\.date)
        var date
        @Dependency(\.uuid)
        var uuid

        let signingKey = try P256.Signing.PrivateKey(rawRepresentation: key)
        let publicKey = signingKey.publicKey.x963Representation
        let jwk = [
          "kty": "EC",
          "crv": "P-256",
          "x": publicKey[1..<33].base64URLEncodedString(),
          "y": publicKey[33..<65].base64URLEncodedString(),
        ]
        let header: [String: Any] = [
          "typ": parameters.keyType,
          "alg": "ES256",
          "jwk": jwk,
        ]
        var claims: [String: Any] = [
          "jti": uuid.callAsFunction().uuidString,
          "htm": parameters.httpMethod,
          "htu": parameters.requestEndpoint,
          "iat": Int(date.callAsFunction().timeIntervalSince1970),
        ]
        if let nonce = parameters.nonce {
          claims["nonce"] = nonce
        }
        if let tokenHash = parameters.tokenHash {
          claims["ath"] = tokenHash
        }

        let headerLayer = try JSONSerialization.data(withJSONObject: header).base64URLEncodedString()
        let claimsLayer = try JSONSerialization.data(withJSONObject: claims).base64URLEncodedString()
        let input = "\(headerLayer).\(claimsLayer)"
        let signature = try signingKey.signature(for: Data(input.utf8))
        let jwt = "\(input).\(signature.rawRepresentation.base64URLEncodedString())"

        return jwt
      }
    }
  }
}

// MARK: - Implementation
private extension BlueskyOAuthClient {
  final actor Implementation: GlobalActor {
    // MARK: - Properties
    static let shared: Implementation = .init()

    // MARK: - Dependency
    @Dependency(\.date)
    private var date
    @Dependency(\.secureKeyValueStore)
    private var secureKeyValueStore
    @Dependency(\.uuid)
    private var uuid

    // MARK: - Initialize
    init() {
    }

    func makeAuthenticator(
      handle: String,
      did: BlueskyAccount.DID,
      server: ServerMetadata,
      key: Data,
    ) async throws -> Authenticator {
      let clientConfig = try await ClientMetadata.load(
        for: "https://nowplaying.nnsnodnb.moe/bsky/client-metadata.json",
        provider: URLSession.defaultProvider,
      )

      let loginStorage = LoginStorage(
        retrieveLogin: { [weak self] in
          try await self?.secureKeyValueStore.getBlueskyAccountLogin(did)
        },
        storeLogin: { [weak self] login in
          try await self?.secureKeyValueStore.setBlueskyAccountLogin(did, login)
        },
      )
      let tokenHandling = Bluesky.tokenHandling(
        account: handle,
        server: server,
        jwtGenerator: DPoP.generate(key: key),
        validator: { tokenResponse, issuer in
          (
            tokenResponse.sub == did.rawValue
            && tokenResponse.scope == "atproto transition:generic"
            && server.issuer == issuer
          )
        },
      )
      let config = Authenticator.Configuration(
        appCredentials: clientConfig.credentials,
        loginStorage: loginStorage,
        tokenHandling: tokenHandling,
        userAuthenticator: ASWebAuthenticationSession.userAuthenticator,
      )
      let authenticator = Authenticator(config: config)

      return authenticator
    }

    private static func isUseDPoPNonce(data: Data, httpURLResponse: HTTPURLResponse) -> Bool {
      if let body = String(data: data, encoding: .utf8), body.contains("use_dpop_nonce") {
        return true
      }
      let authenticate = httpURLResponse.value(forHTTPHeaderField: "WWW-Authenticate") ?? ""
      return authenticate.contains("use_dpop_nonce")
    }

    private func resign(proof: String, nonce: String, key: Data) throws -> String {
      let parts = proof.split(separator: ".").map(String.init)
      guard parts.count == 3,
            let payloadData = parts[1].base64URLDecodedString(),
            var claims = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
        throw Error.dPoPInvalidProof
      }

      claims["nonce"] = nonce
      claims["jti"] = uuid.callAsFunction().uuidString
      claims["iat"] = Int(date.callAsFunction().timeIntervalSince1970)

      let claimsLayer = try JSONSerialization.data(withJSONObject: claims).base64URLEncodedString()
      let input = "\(parts[0]).\(claimsLayer)"
      let signingKey = try P256.Signing.PrivateKey(rawRepresentation: key)
      let signature = try signingKey.signature(for: Data(input.utf8))
      let jwt = "\(input).\(signature.rawRepresentation.base64URLEncodedString())"

      return jwt
    }
  }
}

// MARK: - ResourceResponse
private extension BlueskyOAuthClient {
  struct ResourceResponse: Decodable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case resource
      case authorizationServers = "authorization_servers"
      case bearerMethodsSupported = "bearer_methods_supported"
      case resourceDocumentation = "resource_documentation"
    }

    // MARK: - Properties
    let resource: String
    let authorizationServers: [URL]
    let bearerMethodsSupported: [String]
    let resourceDocumentation: URL
  }
}
