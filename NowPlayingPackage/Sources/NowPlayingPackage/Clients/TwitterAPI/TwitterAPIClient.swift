//
//  TwitterAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct TwitterAPIClient: Sendable {
  public var getUserMe: @Sendable (TwitterOAuthToken) async throws -> TwitterProfile

  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }
}

// MARK: - DependencyKey
extension TwitterAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getUserMe: { oauthToken in
      let accessToken = oauthToken.accessToken
      var urlComponents = URLComponents(string: "https://api.x.com")!
      urlComponents.path = "/2/users/me"
      urlComponents.queryItems = [
        .init(name: "user.fields", value: "id,profile_image_url,username,name"),
      ]
      guard let url = urlComponents.url else {
        throw Error.internalError
      }
      var urlRequest = URLRequest(url: url)
      urlRequest.addValue("Bearer \(accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
      let jsonDecoder = JSONDecoder()
      let object = try jsonDecoder.decode(TwitterAPIResponse<TwitterProfile>.self, from: data)

      return object.data
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var twitterAPI: TwitterAPIClient {
    get {
      self[TwitterAPIClient.self]
    }
    set {
      self[TwitterAPIClient.self] = newValue
    }
  }
}
