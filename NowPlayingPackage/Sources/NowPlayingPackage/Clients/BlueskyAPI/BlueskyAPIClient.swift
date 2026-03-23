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
  public var createPostRecord: @Sendable (BlueskyAccount, String, Data?) async throws -> Void

  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidHandleOrPassword
    case enabledTwoFactorAuthentication
    case invalidHandle
    case requiredLogin
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
    createPostRecord: { blueskyAccount, text, imageData in
      @Dependency(\.secureKeyValueStore)
      var secureKeyValueStore

      guard let password = try await secureKeyValueStore.getBlueskyAccountPassword(blueskyAccount) else {
        throw Error.requiredLogin
      }
      let config = ATProtocolConfiguration()
      try await config.authenticate(with: blueskyAccount.handle, password: password.rawValue)
      let atProtoKit = await ATProtoKit(sessionConfiguration: config)
      let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProtoKit)
      let embedIdentifier: ATProtoBluesky.EmbedIdentifier?
      if let imageData {
        embedIdentifier = .images(
          images: [
            .init(imageData: imageData, fileName: "image.jpeg", altText: text, aspectRatio: nil),
          ],
        )
      } else {
        embedIdentifier = nil
      }
      _ = try await atProtoBluesky.createPostRecord(
        text: text,
        embed: embedIdentifier,
      )
    },
  )
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
