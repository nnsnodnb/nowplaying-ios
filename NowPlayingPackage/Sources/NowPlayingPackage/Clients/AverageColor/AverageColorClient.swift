//
//  AverageColorClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/28.
//

import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct AverageColorClient: Sendable {
  public var make: @Sendable (UIImage) throws -> UIColor
}

// MARK: - DependencyKey
extension AverageColorClient: DependencyKey {
  public static let liveValue: Self = .init(
    make: { image in
      let ciImage = CIImage(image: image)

      let extent = ciImage!.extent
      let filter = CIFilter(
        name: "CIAreaAverage",
        parameters: [kCIInputImageKey: ciImage!, kCIInputExtentKey: CIVector(cgRect: extent)],
      )!

      let outputImage = filter.outputImage!
      var bitmap = [UInt8](repeating: 0, count: 4)
      CIContext().render(
        outputImage,
        toBitmap: &bitmap,
        rowBytes: 4,
        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
        format: .RGBA8,
        colorSpace: nil,
      )

      let averageColor = UIColor(
        red: CGFloat(bitmap[0]) / 255,
        green: CGFloat(bitmap[1]) / 255,
        blue: CGFloat(bitmap[2]) / 255,
        alpha: 1,
      )

      return averageColor.appleMusicStyleAdjusted()
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var averageColor: AverageColorClient {
    get {
      self[AverageColorClient.self]
    }
    set {
      self[AverageColorClient.self] = newValue
    }
  }
}
