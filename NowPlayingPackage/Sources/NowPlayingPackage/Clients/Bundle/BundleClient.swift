//
//  BundleClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BundleClient: Sendable {
  public var shortVersionString: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
  public static let liveValue: Self = .init(
    shortVersionString: {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var bundle: BundleClient {
    get {
      self[BundleClient.self]
    }
    set {
      self[BundleClient.self] = newValue
    }
  }
}
