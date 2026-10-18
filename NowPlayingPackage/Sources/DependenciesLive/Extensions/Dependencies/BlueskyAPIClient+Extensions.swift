//
//  BlueskyAPIClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import CommonModule
import Dependencies
import DependenciesInterfaces
import Foundation
import OAuthenticator

public extension BlueskyAPIClient {
  static let oAuthenticator: Self = .init(
    getUserProfile: { handle, identity in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore
      @Dependency(\.blueskyOAuth)
      var blueskyOAuth

      let key = try await secureKeyValueStore.getBlueskyAccountPrivateKey(identity.did)
      let server = try await Self.loadServerMetadata(identity: identity)
      let authenticator = try await blueskyOAuth.makeAuthenticator(handle: handle, identity: identity, key: key)

      let url = identity.pds.appending(path: "xrpc/app.bsky.actor.getProfile")
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
      components.queryItems = [
        .init(name: "actor", value: identity.did.rawValue),
      ]

      var urlRequest = URLRequest(url: components.url!)
      urlRequest.httpMethod = "GET"

      let (data, response) = try await authenticator.response(for: urlRequest)
      guard let httpURLResponse = response as? HTTPURLResponse,
            httpURLResponse.statusCode == 200 else {
        throw Error.unknown
      }
      let blueskyAccount = try JSONDecoder().decode(BlueskyAccount.self, from: data)
      return blueskyAccount
    },
    uploadBlob: { blueskyAccount, imageData in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore
      @Dependency(\.blueskyOAuth)
      var blueskyOAuth

      guard let identity = try await secureKeyValueStore.getBlueskyAccountIdentity(blueskyAccount.id) else {
        throw Error.requiredLogin
      }
      let key = try await secureKeyValueStore.getBlueskyAccountPrivateKey(identity.did)
      let server = try await Self.loadServerMetadata(identity: identity)
      let authenticator = try await blueskyOAuth.makeAuthenticator(handle: blueskyAccount.handle, identity: identity, key: key)

      let url = identity.pds.appending(path: "xrpc/com.atproto.repo.uploadBlob")
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = imageData
      let (body, _) = try await authenticator.response(for: urlRequest)

      let blobResponse = try JSONDecoder().decode(UploadBlobResponse.self, from: body)

      return blobResponse.blob
    },
    createPostRecord: { blueskyAccount, text, blobRef in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore
      @Dependency(\.blueskyOAuth)
      var blueskyOAuth
      @Dependency(\.date)
      var date

      guard let identity = try await secureKeyValueStore.getBlueskyAccountIdentity(blueskyAccount.id) else {
        throw Error.requiredLogin
      }
      let key = try await secureKeyValueStore.getBlueskyAccountPrivateKey(identity.did)
      let server = try await Self.loadServerMetadata(identity: identity)
      let authenticator = try await blueskyOAuth.makeAuthenticator(handle: blueskyAccount.handle, identity: identity, key: key)

      let embed: CreateRecordBody.Record.Embed? = if let blobRef {
        .init(images: [.init(alt: text, image: blobRef, aspectRatio: nil)])
      } else {
        nil
      }
      let record = CreateRecordBody.Record(
        text: text,
        createdAt: ISO8601DateFormatter().string(from: date.callAsFunction()),
        embed: embed,
        facets: BlueskyFacetBuilder.hashTag(in: text),
      )
      let body = CreateRecordBody(repo: blueskyAccount.id.rawValue, record: record)

      let url = identity.pds.appending(path: "xrpc/com.atproto.repo.createRecord")
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try JSONEncoder().encode(body)
      let (_, response) = try await authenticator.response(for: urlRequest)

      if let httpURLResponse = response as? HTTPURLResponse, !(200..<300).contains(httpURLResponse.statusCode) {
        throw Error.unknown
      }
    },
  )
}

// MARK: - Private methods
private extension BlueskyAPIClient {
  static func loadServerMetadata(identity: BlueskyAccount.Identity) async throws -> ServerMetadata {
    let url = URL(string: identity.serverMetadata.issuer)!.appending(path: "/.well-known/oauth-authorization-server")
    var urlRequst = URLRequest(url: url)
    urlRequst.setValue("application/json", forHTTPHeaderField: "Accept")
    let (data, _) = try await URLSession.shared.data(for: urlRequst)
    let serverMetadata = try JSONDecoder().decode(ServerMetadata.self, from: data)

    return serverMetadata
  }
}

// MARK: - UploadBlobResponse
private extension BlueskyAPIClient {
  struct UploadBlobResponse: Decodable {
    // MARK: - Properties
    let blob: BlueskyBlobRef
  }
}

// MARK: - CreateRecordBody
private extension BlueskyAPIClient {
  struct CreateRecordBody: Encodable {
    struct Record: Encodable {
      struct Embed: Encodable {
        struct Image: Encodable {
          struct Ratio: Encodable {
            // MARK: - Properties
            let width: Int
            let height: Int
          }

          // MARK: - Properties
          let alt: String
          let image: BlueskyBlobRef
          let aspectRatio: Ratio?
        }

        // MARK: - CodingKeys
        private enum CodingKeys: String, CodingKey {
          case type = "$type"
          case images
        }

        // MARK: - Properties
        let type = "app.bsky.embed.images"
        let images: [Image]
      }

      // MARK: - CodingKeys
      private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case text
        case createdAt
        case embed
        case facets
      }

      // MARK: - Properties
      let type = "app.bsky.feed.post"
      let text: String
      let createdAt: String
      let embed: Embed?
      let facets: [BlueskyFacet]?
    }

    // MARK: - Properties
    let repo: String
    let collection = "app.bsky.feed.post"
    let record: Record
  }
}
