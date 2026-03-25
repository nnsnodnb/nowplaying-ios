//
//  APIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct APIClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }

  public var getPostTickets: @Sendable () async throws -> [PostTicket]
}

// MARK: - DependencyKey
extension APIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getPostTickets: {
      let url = URL(string: "https://nowplaying.nnsnodnb.moe/post_ticket.json")!
      let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()

      let object = try decoder.decode(Response<PostTicket>.self, from: data)
      return object.results
    },
  )
}

// MARK: - Response
private extension APIClient {
  struct Response<T: Decodable>: Decodable {
    let results: [T]
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var apiClient: APIClient {
    get {
      self[APIClient.self]
    }
    set {
      self[APIClient.self] = newValue
    }
  }
}
