//
//  FunctionsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import CommonModule
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FunctionsClient: Sendable {
  public var endpointURLString: @Sendable () -> String = { "" }
  public var migrateTwitterUserProfiles: @Sendable ([Migration.V320]) async throws -> Void
  public var getTwitterUserProfile: @Sendable (TwitterProfile.ID) async throws -> TwitterProfile
  public var twitterPostTweet: @Sendable (TwitterProfile.ID, String, TwitterMedia.ID?) async throws -> Void
}

// MARK: - DependencyKey
extension FunctionsClient: DependencyKey {
  public static let liveValue: Self = .init(
    endpointURLString: {
      fatalError("Please set a value for `FunctionsClient.liveValue`.")
    },
    migrateTwitterUserProfiles: { _ in
      fatalError("Please set a value for `FunctionsClient.liveValue`.")
    },
    getTwitterUserProfile: { _ in
      fatalError("Please set a value for `FunctionsClient.liveValue`.")
    },
    twitterPostTweet: { _, _, _ in
      fatalError("Please set a value for `FunctionsClient.liveValue`.")
    },
  )
  public static let previewValue: Self = .init(
    endpointURLString: { "https://example.com" },
    migrateTwitterUserProfiles: { _ in },
    getTwitterUserProfile: { _ in .nnsnodnb },
    twitterPostTweet: { _, _, _ in }
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var functions: FunctionsClient {
    get {
      self[FunctionsClient.self]
    }
    set {
      self[FunctionsClient.self] = newValue
    }
  }
}
