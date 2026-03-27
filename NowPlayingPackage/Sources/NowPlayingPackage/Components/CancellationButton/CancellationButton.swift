//
//  CancellationButton.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/27.
//

import SwiftUI

public struct CancellationButton: View {
  // MARK: - Properties
  public let action: @Sendable @MainActor () -> Void

  // MARK: - Body
  public var body: some View {
    if #available(iOS 26.0, *) {
      Button(
        role: .close,
        action: action,
      )
    } else {
      Button(
        action: action,
        label: {
          Image(systemSymbol: .xmark)
        },
      )
    }
  }
}

#Preview {
  CancellationButton(
    action: {},
  )
}
