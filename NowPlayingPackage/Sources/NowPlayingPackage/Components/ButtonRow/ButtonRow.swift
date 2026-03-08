//
//  SwiftUIView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/07.
//

import SwiftUI

public struct ButtonRow<Icon: View>: View {
  // MARK: - Properties
  public let action: @MainActor () -> Void
  public let title: String
  public let icon: () -> Icon

  // MARK: - Body
  public var body: some View {
    Button(
      action: action,
      label: {
        HStack(alignment: .center, spacing: 0) {
          Label(
            title: {
              Text(title)
                .foregroundStyle(Color.primary)
            },
            icon: icon,
          )
          Spacer()
          chevronAnchor
        }
      },
    )
  }

  private var chevronAnchor: some View {
    Image(systemSymbol: .chevronRight)
      .font(.system(size: 14, weight: .semibold))
      .foregroundStyle(Color.secondary)
      .opacity(0.5)
  }
}

#Preview {
  ButtonRow(
    action: {},
    title: "テキスト",
    icon: {
      Image(systemSymbol: .appleLogo)
        .resizable()
    }
  )
}
