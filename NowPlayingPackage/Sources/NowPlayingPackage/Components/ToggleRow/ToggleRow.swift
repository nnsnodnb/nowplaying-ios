//
//  ToggleRow.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import SwiftUI

public struct ToggleRow<Icon: View>: View {
  // MARK: - Properties
  @Binding public var isOn: Bool
  public var title: String
  public var icon: () -> Icon

  // MARK: - Body
  public var body: some View {
    Toggle(
      isOn: $isOn,
      label: {
        Label(
          title: {
            Text(title)
          },
          icon: icon,
        )
      }
    )
  }
}

#Preview {
  ToggleRow(
    isOn: .constant(true),
    title: "テキスト",
    icon: {
      Image(systemSymbol: .photo)
        .resizable()
        .scaledToFit()
    }
  )
}
