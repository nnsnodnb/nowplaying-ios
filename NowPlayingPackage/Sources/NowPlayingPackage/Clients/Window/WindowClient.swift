//
//  WindowClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct WindowClient: Sendable {
  public var make: @Sendable @MainActor () throws -> UIWindow
}

// MARK: - DependencyKey
extension WindowClient: DependencyKey {
  public static let liveValue: Self = .init(
    make: {
      let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
      let window = scene?.keyWindow
      return window ?? .init()
    },
  )
}

// MARK: - DependencyKey
public extension DependencyValues {
  var window: WindowClient {
    get {
      self[WindowClient.self]
    }
    set {
      self[WindowClient.self] = newValue
    }
  }
}
