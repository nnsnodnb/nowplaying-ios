//
//  AuthClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/14.
//

import Dependencies
import DependenciesMacros
import FirebaseAuth
import Foundation

@DependencyClient
public struct AuthClient: Sendable {
  public var isSignedIn: @Sendable () -> Bool = { false }
  public var currentUserID: @Sendable () -> String?
  public var isAnonymous: @Sendable () -> Bool = { false }
  public var signInAnonymously: @Sendable () async throws -> Void
  public var signOut: @Sendable () throws -> Void
}

// MARK: - DependencyKey
extension AuthClient: DependencyKey {
  public static let liveValue: Self = .init(
    isSignedIn: {
      Auth.auth().currentUser != nil
    },
    currentUserID: {
      Auth.auth().currentUser?.uid
    },
    isAnonymous: {
      Auth.auth().currentUser?.isAnonymous == true
    },
    signInAnonymously: {
      _ = try await Auth.auth().signInAnonymously()
    },
    signOut: {
      try Auth.auth().signOut()
    },
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
