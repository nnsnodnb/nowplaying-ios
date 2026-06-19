//
//  RewardedAdClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct RewardedAdClient: Sendable {
  // MARK: - Error
  public enum Error: Swift.Error {
    case interruption
    case loadError(String)
  }

  public var load: @Sendable (String) async throws -> Void
  public var show: @Sendable (String) async throws -> Int
}

// MARK: - DependencyKey
extension RewardedAdClient: DependencyKey {
  public static let liveValue: Self = .init(
    load: { _ in
      fatalError("Please set a value for `RewardedAdClient.liveValue`.")
    },
    show: { _ in
      fatalError("Please set a value for `RewardedAdClient.liveValue`.")
    },
  )
  public static let previewValue: Self = .init(
    load: { _ in },
    show: { _ in 1 },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var rewardedAd: RewardedAdClient {
    get {
      self[RewardedAdClient.self]
    }
    set {
      self[RewardedAdClient.self] = newValue
    }
  }
}
