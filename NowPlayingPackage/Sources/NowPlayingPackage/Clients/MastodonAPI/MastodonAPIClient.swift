//
//  MastodonAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import Dependencies
import DependenciesMacros
import Foundation

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
      let domainURL = URL(string: "https://\(domain)")!
      let requestURL = URL(string: "https://\(domain)/api/v1/apps")!
      var urlRequest = URLRequest(url: requestURL)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      let jsonObject: [String: Any] = [
        "client_name": "NowPlayingiOS",
        "redirect_uris": "nowplaying-ss5dnc-el0eskszufn3qactsets://callback/oauth",
        "scopes": "read:accounts write:media write:statuses",
        "website": "https://nowplaying.nnsnodnb.moe",
      ]
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
      let decoder = JSONDecoder()
      let object = try decoder.decode(MastodonCredentialApplication.self, from: data)
      let clientApplication = MastodonClientApplication(
        id: object.id,
        domainURL: domainURL,
        redirectURI: object.redirectURI,
        clientID: object.clientID,
        clientSecret: object.clientSecret,
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
