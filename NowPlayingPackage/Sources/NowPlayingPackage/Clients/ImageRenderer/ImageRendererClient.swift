//
//  ImageRendererClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct ImageRendererClient: Sendable {
  public var image: @Sendable @MainActor () throws -> UIImage
}

// MARK: - DependencyKey
extension ImageRendererClient: DependencyKey {
  public static let liveValue: Self = .init(
    image: {
      @Dependency(\.window.make)
      var window

      let keyWindow = try window()
      let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds)
      let image = renderer.image { _ in
        keyWindow.drawHierarchy(in: keyWindow.bounds, afterScreenUpdates: true)
      }
      return image
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var imageRenderer: ImageRendererClient {
    get {
      self[ImageRendererClient.self]
    }
    set {
      self[ImageRendererClient.self] = newValue
    }
  }
}
