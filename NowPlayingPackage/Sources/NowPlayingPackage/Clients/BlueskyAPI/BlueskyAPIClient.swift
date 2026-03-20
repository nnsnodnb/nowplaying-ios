//
//  BlueskyAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import ATProtoKit
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BlueskyAPIClient: Sendable {
  public var login: @Sendable (String, String) async throws -> BlueskyAccount
  public var getAccessToken: @Sendable (BlueskyAccount) async throws -> BlueskyOAuthToken.AccessToken
  public var uploadMedia: @Sendable (BlueskyOAuthToken.AccessToken, Data) async throws -> Void

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidHandleOrPassword
    case enabledTwoFactorAuthentication
    case invalidHandle
    case unknown
  }
}

// MARK: - DependencyKey
extension BlueskyAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    login: { handle, password in
      let config = ATProtocolConfiguration(pdsURL: "https://bsky.social")
      do {
        try await config.authenticate(with: handle, password: password)
      } catch let error as ATAPIError {
        switch error {
        case let .badRequest(error: responseError):
          if responseError.error == "AuthFactorTokenRequired" {
            throw Error.enabledTwoFactorAuthentication
          }
        default:
          throw Error.invalidHandleOrPassword
        }
      } catch {
        throw Error.unknown
      }
      let atProtoKit = await ATProtoKit(sessionConfiguration: config)
      do {
        let profile = try await atProtoKit.getProfile(for: handle)
        let blueskyAccount = BlueskyAccount(
          id: .init(profile.actorDID),
          handle: profile.actorHandle,
          displayName: profile.displayName,
          avatarImageURL: profile.avatarImageURL,
          password: password,
          isDefault: false,
        )

        return blueskyAccount
      } catch let error as ATAPIError {
        switch error {
        case let .badRequest(error: responseError):
          if responseError.message == "Profile not found" {
            throw Error.invalidHandle
          } else {
            throw Error.unknown
          }
        default:
          throw Error.unknown
        }
      } catch {
        throw Error.unknown
      }
    },
    getAccessToken: { blueskyAccount in
      let config = ATProtocolConfiguration()
      try await config.authenticate(with: blueskyAccount.handle, password: blueskyAccount.password)
      let accessToken = try await Self.retrieveAccessToken(config: config)

      return accessToken
    },
    uploadMedia: { accessToken, imageData in
      let atProtoKit = await ATProtoKit()
      let response = try await atProtoKit.uploadBlob(
        accessToken: accessToken.rawValue,
        filename: "image.jpeg",
        imageData: imageData,
      )

      _ = response.blob
    },
  )

  private static func retrieveAccessToken(
    config: any SessionConfiguration,
  ) async throws -> BlueskyOAuthToken.AccessToken {
    let accessToken = try await config.keychainProtocol.retrieveAccessToken()

    return .init(accessToken)
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var blueskyAPI: BlueskyAPIClient {
    get {
      self[BlueskyAPIClient.self]
    }
    set {
      self[BlueskyAPIClient.self] = newValue
    }
  }
}
