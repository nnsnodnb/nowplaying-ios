//
//  PressScaleButtonStyle.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import SwiftUI

public struct PressScaleButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.8 : 1)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

public extension ButtonStyle where Self == PressScaleButtonStyle {
  static var pressScale: PressScaleButtonStyle {
    .init()
  }
}
