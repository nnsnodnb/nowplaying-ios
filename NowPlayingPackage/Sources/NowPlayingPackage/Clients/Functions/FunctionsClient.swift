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
  public var endpointURLString: @Sendable () -> String = { "" }
  public var migrateTwitterUserProfiles: @Sendable ([Migration.V320]) async throws -> Void
  public var getTwitterUserProfile: @Sendable (TwitterProfile.ID) async throws -> TwitterProfile
  public var twitterPostTweet: @Sendable (TwitterProfile.ID, String, TwitterMedia.ID?) async throws -> Void

  fileprivate static let functions = Functions.functions(region: "asia-northeast1")
  fileprivate static let _endpointURLString = "https://asia-northeast1-nowplayingios.cloudfunctions.net"
}

// MARK: - DependencyKey
extension FunctionsClient: DependencyKey {
  public static let liveValue: Self = .init(
    endpointURLString: {
      Self._endpointURLString
    },
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
    getTwitterUserProfile: { twitterProfileID in
      let callable = Self.functions.httpsCallable(
        "get_twitter_user_profile",
        requestAs: GetTwitterUserProfileRequest.self,
        responseAs: TwitterProfile.self,
      )
      let request = GetTwitterUserProfileRequest(userID: twitterProfileID)
      let twitterProfile = try await callable.call(request)
      return twitterProfile
    },
    twitterPostTweet: { twitterProfileID, text, mediaID in
      let options = HTTPSCallableOptions(requireLimitedUseAppCheckTokens: true)
      let callable = Self.functions.httpsCallable(
        "twitter_post_tweet",
        options: options,
        requestAs: TwitterPostTweetRequest.self,
        responseAs: VoidResponse.self,
      )
      let request = TwitterPostTweetRequest(text: text, userID: twitterProfileID, mediaID: mediaID)
      _ = try await callable.call(request)
    },
  )
}

// MARK: - VoidResponse
private extension FunctionsClient {
  struct VoidResponse: Decodable {
  }
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

// MARK: - GetTwitterUserProfileRequest
private extension FunctionsClient {
  struct GetTwitterUserProfileRequest: Encodable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case userID = "user_id"
    }

    // MARK: - Properties
    let userID: TwitterProfile.ID
  }
}

// MARK: - TwitterPostTweetRequest
private extension FunctionsClient {
  struct TwitterPostTweetRequest: Encodable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case text
      case userID = "user_id"
      case mediaID = "media_id"
    }

    // MARK: - Properties
    let text: String
    let userID: TwitterProfile.ID
    let mediaID: TwitterMedia.ID?
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
