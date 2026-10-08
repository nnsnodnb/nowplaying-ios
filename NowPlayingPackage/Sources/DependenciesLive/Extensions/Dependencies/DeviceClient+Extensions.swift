//
//  DeviceClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/08.
//

import DependenciesInterfaces
import UIKit

public extension DeviceClient {
  static let uiKit: Self = .init(
    currentOrientation: { @MainActor in UIDevice.current.orientation },
  )
}
