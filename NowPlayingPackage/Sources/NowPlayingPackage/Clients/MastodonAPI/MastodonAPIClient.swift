//
//  MastodonAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import Dependencies
import DependenciesMacros
import Foundation
import MastodonKit

@DependencyClient
public struct MastodonAPIClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidURL
    case internalError
  }

  public var getInstanceDetail: @Sendable (URL) async throws -> MastodonInstance
  public var registerApplication: @Sendable (String) async throws -> MastodonClientApplication
}

// MARK: - DependencyKey
extension MastodonAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getInstanceDetail: { domainURL in
      var urlComponents = URLComponents(url: domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/api/v2/instance"
      guard let url = urlComponents.url else {
        throw Error.invalidURL
      }
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(MastodonInstance.self, from: data)

      return object
    },
    registerApplication: { domain in
      var domainURL = URL(string: "https://\(domain)")!
      let client = Client(baseURL: domainURL.absoluteString)
      let request = Clients.register(
        clientName: "NowPlayingiOS",
        redirectURI: "nowplaying-ss5dnc-el0eskszufn3qactsets://callback/oauth",
        scopes: [.read, .write],
        website: "https://nowplaying.nnsnodnb.moe",
      )
      let response = try await client.response(for: request)
      let clientApplication = MastodonClientApplication(
        id: .init(response.id),
        domainURL: domainURL,
        redirectURI: response.redirectURI,
        clientID: .init(response.clientID),
        clientSecret: .init(response.clientSecret),
      )

      return clientApplication
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var mastodonAPI: MastodonAPIClient {
    get {
      self[MastodonAPIClient.self]
    }
    set {
      self[MastodonAPIClient.self] = newValue
    }
  }
}
