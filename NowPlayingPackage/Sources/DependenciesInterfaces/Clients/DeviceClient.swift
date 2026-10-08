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
  public var streamOrientation: @Sendable () async throws -> AsyncStream<UIDeviceOrientation>
}

// MARK: - DependencyKey
extension DeviceClient: DependencyKey {
  public static let liveValue: Self = .init(
    streamOrientation: {
      AsyncStream {
        $0.yield(.portrait)
        $0.finish()
      }
    },
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
