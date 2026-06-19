//
//  BlueskyAPIClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BlueskyAPIClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case invalidHandleOrPassword
    case enabledTwoFactorAuthentication
    case invalidHandle
    case requiredLogin
    case unknown
  }

  public var login: @Sendable (String, String) async throws -> BlueskyAccount
  public var createPostRecord: @Sendable (BlueskyAccount, String, Data?) async throws -> Void
}

// MARK: - DependencyKey
extension BlueskyAPIClient: DependencyKey {
  public static let liveValue: Self = .init(
    login: { _, _ in
      fatalError("Please set a value for `BlueskyAPIClient.liveValue`.")
    },
    createPostRecord: { _, _, _ in
      fatalError("Please set a value for `BlueskyAPIClient.liveValue`.")
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
