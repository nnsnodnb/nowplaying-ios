//
//  UIColor+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/28.
//

import UIKit

// swiftlint:disable identifier_name
extension UIColor {
  var luminance: CGFloat {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    getRed(&r, green: &g, blue: &b, alpha: &a)

    func adjust(_ c: CGFloat) -> CGFloat {
      (c <= 0.03928) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4)
    }

    let R = adjust(r)
    let G = adjust(g)
    let B = adjust(b)

    return 0.2126 * R + 0.7152 * G + 0.0722 * B
  }

  func appleMusicStyleAdjusted(threshold: CGFloat = 0.85) -> UIColor {
    guard luminance > threshold else {
      return self
    }

    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    getHue(&h, saturation: &s, brightness: &b, alpha: &a)

    return UIColor(
      hue: h,
      saturation: min(s + 0.15, 1.0),
      brightness: b * 0.65,
      alpha: a,
    )
  }
}
// swiftlint:enable identifier_name
