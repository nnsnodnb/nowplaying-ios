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
  public var buildVersion: @Sendable () -> Int = { 0 }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
  public static let liveValue: Self = .init(
    shortVersionString: {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    },
    buildVersion: {
      let stringValue = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
      return Int(stringValue) ?? 0
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
