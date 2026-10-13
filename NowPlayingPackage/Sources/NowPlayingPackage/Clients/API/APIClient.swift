//
//  APIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct APIClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }

  public var getAppInfo: @Sendable () async throws -> AppInfo
  public var getPostTickets: @Sendable () async throws -> [PostTicket]
}

// MARK: - DependencyKey
extension APIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getAppInfo: {
      let url = URL(string: "https://nowplaying.nnsnodnb.moe/app_info.json")!
      var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(AppInfo.self, from: data)

      return object
    },
    getPostTickets: {
      let url = URL(string: "https://nowplaying.nnsnodnb.moe/post_ticket.json")!
      let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)
      guard let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 else { throw Error.internalError }
      let decoder = JSONDecoder()
      let object = try decoder.decode(PostTicketResponse<PostTicket>.self, from: data)

      return object.versions.v2.results
    },
  )
}

// MARK: - PostTicketResponse
private extension APIClient {
  struct PostTicketResponse<T: Decodable>: Decodable {
    // MARK: - Versions
    struct Versions: Decodable {
      // MARK: - V2
      struct V2: Decodable {
        let results: [T]
      }

      let v2: V2 // swiftlint:disable:this identifier_name
    }

    let versions: Versions
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
