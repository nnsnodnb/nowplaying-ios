//
//  ConfirmationButton.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/27.
//

import SwiftUI

public struct ConfirmationButton: View {
  // MARK: - Properties
  public let action: @Sendable @MainActor () -> Void
  public let title: String

  // MARK: - Body
  public var body: some View {
    if #available(iOS 26.0, *) {
      Button(
        role: .confirm,
        action: action,
        label: {
          Text(title)
        },
      )
    } else {
      Button(
        action: action,
        label: {
          Text(title)
        },
      )
    }
  }
}

#Preview {
  ConfirmationButton(
    action: {},
    title: "確認",
  )
}
