//
//  DeviceClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/08.
//

import Dependencies
import DependenciesInterfaces
import UIKit

public extension DeviceClient {
  static let uiKit: Self = .init(
    streamOrientation: { @MainActor in
      AsyncStream { continuation in
        Task { @MainActor in
          UIDevice.current.beginGeneratingDeviceOrientationNotifications()
          continuation.yield(UIDevice.current.orientation)
        }

        @Dependency(\.notificationCenter)
        var notificationCenter

        let task = Task {
          for await _ in notificationCenter.notifications(named: UIDevice.orientationDidChangeNotification) {
            guard !Task.isCancelled else {
              continuation.finish()
              return
            }
            let orientation = await MainActor.run {
              UIDevice.current.orientation
            }
            continuation.yield(orientation)
          }
        }

        continuation.onTermination = { _ in
          task.cancel()
          Task { @MainActor in
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
          }
        }
      }
    },
  )
}
