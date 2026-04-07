//
//  MastodonAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import Dependencies
import DependenciesMacros
import Foundation
import Tagged

@DependencyClient
public struct MastodonAPIClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidURL
    case internalError
  }

  public var getInstanceDetail: @Sendable (URL) async throws -> MastodonInstance
  public var registerApplication: @Sendable (String) async throws -> MastodonClientApplication
  public var uploadMedia: @Sendable (URL, MastodonOAuthToken.AccessToken, Data) async throws -> MastodonMediaAttachment
  public var toot: @Sendable (
    URL, MastodonOAuthToken.AccessToken, MastodonMediaAttachment.ID?, String, TootVisibilityType
  ) async throws -> Void
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
      let object = try decoder.decode(CredentialApplication.self, from: data)
      let clientApplication = MastodonClientApplication(
        id: object.id,
        domainURL: domainURL,
        redirectURI: object.redirectURI,
        clientID: object.clientID,
        clientSecret: object.clientSecret,
      )

      return clientApplication
    },
    uploadMedia: { domainURL, accessToken, imageData in
      var urlComponents = URLComponents(url: domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/api/v2/media"
      let url = urlComponents.url!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("Bearer \(accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      @Dependency(\.uuid)
      var uuid
      let boundary = "Boundary-\(uuid.callAsFunction().uuidString)"
      urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      var httpBody = Data()
      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
      httpBody.append("Content-Type: image/jpeg\r\n\r\n")
      httpBody.append(imageData)
      httpBody.append("\r\n")

      httpBody.append("--\(boundary)--\r\n")

      urlRequest.httpBody = httpBody

      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
      let jsonDecoder = JSONDecoder()
      let object = try jsonDecoder.decode(MastodonMediaAttachment.self, from: data)

      return object
    },
    toot: { domainURL, accessToken, mediaID, text, visibilityType in
      var urlComponents = URLComponents(url: domainURL, resolvingAgainstBaseURL: false)!
      urlComponents.path = "/api/v1/statuses"
      let url = urlComponents.url!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("Bearer \(accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      var jsonObject: [String: Any] = [
        "status": text,
        "visibility": visibilityType.rawValue,
      ]
      if let mediaID {
        jsonObject["media_ids"] = [mediaID.rawValue]
      }
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())
      let (_, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
    },
  )
}

// MARK: - CredentialApplication
private extension MastodonAPIClient {
  struct CredentialApplication: Decodable, Sendable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case id
      case redirectURI = "redirect_uri"
      case clientID = "client_id"
      case clientSecret = "client_secret"
    }

    // MARK: - Properties
    let id: MastodonClientApplication.ID
    let redirectURI: String
    let clientID: MastodonClientApplication.ClientID
    let clientSecret: MastodonClientApplication.ClientSecret
  }
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
