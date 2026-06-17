//
//  AuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/14.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AuthClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case internalError
  }

  public var isSignedIn: @Sendable () -> Bool = { false }
  public var currentUserID: @Sendable () -> String?
  public var isAnonymous: @Sendable () -> Bool = { false }
  public var signInAnonymously: @Sendable () async throws -> Void
  public var signOut: @Sendable () throws -> Void
  public var getIDToken: @Sendable () async throws -> String
}

// MARK: - DependencyKey
extension AuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    isSignedIn: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
    currentUserID: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
    isAnonymous: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
    signInAnonymously: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
    signOut: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
    getIDToken: {
      fatalError("Please set a value for `AuthClient.liveValue`.")
    },
  )
  public static let previewValue: Self = .init(
    isSignedIn: { true },
    currentUserID: { "stub_current_user_id" },
    isAnonymous: { true },
    signInAnonymously: {},
    signOut: {},
    getIDToken: { "stub_id_token" },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var auth: AuthClient {
    get {
      self[AuthClient.self]
    }
    set {
      self[AuthClient.self] = newValue
    }
  }
}
