//
//  AdClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import CommonModule
import Dependencies
import DependenciesMacros
import SwiftUI

@DependencyClient
public struct AdClient: Sendable {
  public var make: @MainActor (_ adUnitID: String, _ size: BannerSize) -> AnyView = { _, _ in AnyView(EmptyView()) }
}

// MARK: - DependencyKey
extension AdClient: DependencyKey {
  public static let liveValue: Self = .init(
    make: { _, _ in AnyView(EmptyView()) }
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var adClient: AdClient {
    get {
      self[AdClient.self]
    }
    set {
      self[AdClient.self] = newValue
    }
  }
}
