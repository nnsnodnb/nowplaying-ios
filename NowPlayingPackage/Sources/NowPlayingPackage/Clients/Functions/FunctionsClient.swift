//
//  FunctionsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import Dependencies
import DependenciesMacros
import FirebaseFunctions
import Foundation

@DependencyClient
public struct FunctionsClient: Sendable {
  public var migrateTwitterUserProfiles: @Sendable ([Migration.V320]) async throws -> Void

  fileprivate static let functions = Functions.functions(region: "asia-northeast1")
}

// MARK: - DependencyKey
extension FunctionsClient: DependencyKey {
  public static let liveValue: Self = .init(
    migrateTwitterUserProfiles: { migrations in
      let callable = Self.functions.httpsCallable(
        "migrate_twitter_user_profiles",
        requestAs: MigrateTwitterUserProfilesRequest.self,
        responseAs: MigrateTwitterUserProfilesResponse.self,
      )
      let request = MigrateTwitterUserProfilesRequest(
        migrations: migrations.map {
          .init(userProfile: $0.twitterAccount.profile, refreshToken: $0.refreshToken)
        },
      )
      _ = try await callable.call(request)
    },
  )
}

// MARK: - MigrateTwitterUserProfilesRequest
private extension FunctionsClient {
  struct MigrateTwitterUserProfilesRequest: Encodable {
    // MARK: - Migrations
    struct Migration: Encodable {
      // MARK: - CodingKeys
      private enum CodingKeys: String, CodingKey {
        case userProfile = "user_profile"
        case refreshToken = "refresh_token"
      }

      // MARK: - Properties
      let userProfile: TwitterProfile
      let refreshToken: TwitterOAuthToken.RefreshToken
    }

    // MARK: - Properties
    let migrations: [Migration]
  }
}

// MARK: - MigrateTwitterUserProfilesResponse
private extension FunctionsClient {
  struct MigrateTwitterUserProfilesResponse: Decodable {
    // MARK: - Properties
    let status: String
  }
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
