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
  public var getUserMe: @Sendable (TwitterOAuthToken.AccessToken) async throws -> TwitterProfile
  public var uploadMedia: @Sendable (TwitterOAuthToken.AccessToken, Data) async throws -> TwitterMedia
  public var post: @Sendable (TwitterOAuthToken.AccessToken, TwitterMedia.ID?, String) async throws -> Void

  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }
}

// MARK: - DependencyKey
extension TwitterAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getUserMe: { accessToken in
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
    uploadMedia: { accessToken, imageData in
      let url = URL(string: "https://api.x.com/2/media/upload")!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("Bearer \(accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      @Dependency(\.uuid)
      var uuid
      let boundary = "Boundary-\(uuid.callAsFunction().uuidString)"
      urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      var httpBody = Data()
      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"media\"; filename=\"image.jpg\"\r\n")
      httpBody.append("Content-Type: image/jpeg\r\n\r\n")
      httpBody.append(imageData)
      httpBody.append("\r\n")

      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"media_category\"\r\n\r\n")
      httpBody.append("tweet_image\r\n")

      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"media_type\"\r\n\r\n")
      httpBody.append("image/jpeg\r\n")

      httpBody.append("--\(boundary)--\r\n")

      urlRequest.httpBody = httpBody

      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
      let jsonDecoder = JSONDecoder()
      let object = try jsonDecoder.decode(TwitterAPIResponse<TwitterMedia>.self, from: data)

      return object.data
    },
    post: { accessToken, mediaID, text in
      let url = URL(string: "https://api.x.com/2/tweets")!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("Bearer \(accessToken.rawValue)", forHTTPHeaderField: "Authorization")
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      var jsonObject: [String: Any] = [
        "text": text,
      ]
      if let mediaID {
        jsonObject["media"] = [
          "media_ids": [mediaID.rawValue],
        ]
      }
      let httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

      urlRequest.httpBody = httpBody

      let (_, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 201 else {
        throw Error.internalError
      }
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
