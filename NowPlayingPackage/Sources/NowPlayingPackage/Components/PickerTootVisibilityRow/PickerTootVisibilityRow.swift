//
//  PickerTootVisibilityRow.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import SwiftUI

public struct PickerTootVisibilityRow<Content: View>: View {
  // MARK: - Properties
  @Binding public var selection: TootVisibilityType
  public let content: () -> Content

  @State private var iconImage: Image?

  // MARK: - Body
  public var body: some View {
    Picker(
      selection: $selection,
      content: content,
      label: {
        Label(
          title: {
            Text(.tootVisibility)
          },
          icon: {
            iconImage
              .foregroundStyle(Color(.mastodonBrand))
          },
        )
      },
    )
    .pickerStyle(.menu)
    .tint(Color.primary)
    .onChange(of: selection, initial: true) { _, newValue in
      switch newValue {
      case .`public`:
        iconImage = Image(systemSymbol: .globeAmericasFill)
      case .unlisted:
        iconImage = Image(systemSymbol: .lockOpenFill)
      case .`private`:
        iconImage = Image(systemSymbol: .lockFill)
      }
    }
  }
}
