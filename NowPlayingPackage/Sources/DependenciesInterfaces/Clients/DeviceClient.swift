//
//  DeviceClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/07.
//

import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct DeviceClient: Sendable {
  public var currentOrientation: @MainActor @Sendable () throws -> UIDeviceOrientation
}

// MARK: - DependencyKey
extension DeviceClient: DependencyKey {
  public static let liveValue: Self = .init(
    currentOrientation: { .portrait },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var device: DeviceClient {
    get {
      self[DeviceClient.self]
    }
    set {
      self[DeviceClient.self] = newValue
    }
  }
}
