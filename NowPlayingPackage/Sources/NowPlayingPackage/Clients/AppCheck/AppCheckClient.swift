//
//  AppCheckClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/19.
//

import Dependencies
import DependenciesMacros
import FirebaseAppCheck
import Foundation

@DependencyClient
public struct AppCheckClient: Sendable {
  public var token: @Sendable () async throws -> String
}

// MARK: - DependencyKey
extension AppCheckClient: DependencyKey {
  public static let liveValue: Self = .init(
    token: {
      let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
      return appCheckToken.token
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var appCheck: AppCheckClient {
    get {
      self[AppCheckClient.self]
    }
    set {
      self[AppCheckClient.self] = newValue
    }
  }
}
