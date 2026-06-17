//
//  CrashlyticsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/10.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CrashlyticsClient: Sendable {
  public var recordAdBannerLoadError: @Sendable (sending ResponseInfoProtocol?, any Error) throws -> Void
  public var recordRewardedAdLoadError: @Sendable (any Error) throws -> Void
}

// MARK: - DependencyKey
extension CrashlyticsClient: DependencyKey {
  public static let liveValue: Self = .init(
    recordAdBannerLoadError: { _, _ in
      fatalError("Please set a value for `CrashlyticsClient.liveValue`.")
    },
    recordRewardedAdLoadError: { _ in
      fatalError("Please set a value for `CrashlyticsClient.liveValue`.")
    },
  )
  public static let testValue: Self = .init(
    recordAdBannerLoadError: { _, _ in },
    recordRewardedAdLoadError: { _ in },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var crashlytics: CrashlyticsClient {
    get {
      self[CrashlyticsClient.self]
    }
    set {
      self[CrashlyticsClient.self] = newValue
    }
  }
}
