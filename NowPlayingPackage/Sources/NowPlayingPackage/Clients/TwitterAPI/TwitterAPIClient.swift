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
  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }

  public var getUserMe: @Sendable (TwitterProfile.ID) async throws -> TwitterProfile
  public var uploadMedia: @Sendable (TwitterProfile.ID, Data) async throws -> TwitterMedia
  public var post: @Sendable (TwitterProfile.ID, TwitterMedia.ID?, String) async throws -> Void
}

// MARK: - DependencyKey
extension TwitterAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    getUserMe: { twitterProfileID in
      @Dependency(\.functions)
      var functions

      let twitterProfile = try await functions.getTwitterUserProfile(twitterProfileID)
      return twitterProfile
    },
    uploadMedia: { twitterProfileID, imageData in
      @Dependency(\.appCheck)
      var appCheck
      @Dependency(\.auth)
      var auth
      @Dependency(\.functions)
      var functions
      @Dependency(\.uuid)
      var uuid

      let url = URL(string: "\(functions.endpointURLString())/twitter_upload_image")!
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "POST"
      let idToken = try await auth.getIDToken()
      urlRequest.addValue("bearer \(idToken)", forHTTPHeaderField: "Authorization")
      let appCheckToken = try await appCheck.token()
      urlRequest.addValue(appCheckToken, forHTTPHeaderField: "X-Firebase-AppCheck")

      let boundary = "Boundary-\(uuid.callAsFunction().uuidString)"
      urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      var httpBody = Data()
      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
      httpBody.append("Content-Type: image/jpeg\r\n\r\n")
      httpBody.append(imageData)
      httpBody.append("\r\n")

      httpBody.append("--\(boundary)\r\n")
      httpBody.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n")
      httpBody.append("\(twitterProfileID.rawValue)\r\n")

      httpBody.append("--\(boundary)--\r\n")

      urlRequest.httpBody = httpBody

      let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
      guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
        throw Error.internalError
      }
      let jsonDecoder = JSONDecoder()
      let object = try jsonDecoder.decode(TwitterAPIResponse<TwitterMedia>.self, from: data)

      return object.result
    },
    post: { twitterProfileID, mediaID, text in
      @Dependency(\.functions)
      var functions

      try await functions.twitterPostTweet(twitterProfileID, text, mediaID)
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
