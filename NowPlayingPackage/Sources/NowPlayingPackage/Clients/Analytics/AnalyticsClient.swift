//
//  AnalyticsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/28.
//

import Dependencies
import DependenciesMacros
import FirebaseAnalytics
import Foundation

@DependencyClient
public struct AnalyticsClient: Sendable {
  public var logEvent: @Sendable (Event) async -> Void
}

// MARK: - DependencyKey
extension AnalyticsClient: DependencyKey {
  public static let liveValue: Self = .init(
    logEvent: { event in
      FirebaseAnalytics.Analytics.logEvent(
        "event",
        parameters: [:]
      )
    },
  )
}

// MARK: - ScreenName
public extension AnalyticsClient {
  enum ScreenName {
    case root
    case consent
    case play
    case setting
    case twitterSetting
    case twitterAccountManage
    case blueskySetting
    case blueskyAccountManage
    case paidContent
    case license
    case tweet
    case post
  }
}

// MARK: - Event
public extension AnalyticsClient {
  enum Event {
    case launch

    // MARK: - Properties
    var event: String {
      switch self
    }
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var analytics: AnalyticsClient {
    get {
      self[AnalyticsClient.self]
    }
    set {
      self[AnalyticsClient.self] = newValue
    }
  }
}
