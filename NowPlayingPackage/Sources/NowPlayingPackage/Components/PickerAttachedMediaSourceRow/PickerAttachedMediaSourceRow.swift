//
//  PickerAttachedMediaSourceRow.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import SwiftUI

public struct PickerAttachedMediaSourceRow<SelectionValue: Hashable, Content: View>: View {
  // MARK: - Properties
  @Binding public var selection: SelectionValue
  public let content: () -> Content

  // MARK: - Body
  public var body: some View {
    Picker(
      selection: $selection,
      content: content,
      label: {
        Label(
          title: {
            Text("投稿時画像")
          },
          icon: {
            Image(systemSymbol: .musicNote)
          },
        )
      },
    )
    .pickerStyle(.menu)
    .tint(Color.primary)
  }
}

#Preview {
  PickerAttachedMediaSourceRow(
    selection: .constant("Artwork"),
    content: {
      Text("Artwork")
    }
  )
}
