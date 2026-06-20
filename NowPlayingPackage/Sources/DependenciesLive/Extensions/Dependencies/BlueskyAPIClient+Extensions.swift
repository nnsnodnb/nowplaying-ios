//
//  BlueskyAPIClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import ATProtoKit
import CommonModule
import Dependencies
import DependenciesInterfaces
import Foundation

public extension BlueskyAPIClient {
  static let atProtoKit: Self = .init(
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
