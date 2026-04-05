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
  public var getInstanceDetail: @Sendable (URL) async throws -> MastodonInstance

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidURL
    case internalError
  }
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
