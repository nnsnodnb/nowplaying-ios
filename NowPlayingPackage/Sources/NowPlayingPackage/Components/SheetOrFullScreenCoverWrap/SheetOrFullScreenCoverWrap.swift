//
//  SheetOrFullScreenCoverWrap.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/02.
//

import SwiftUI

public struct SheetOrFullScreenCoverWrap<Content: View, Item: Identifiable, Sheet: View>: View {
  // MARK: - Properties
  public let content: () -> Content
  public let item: Binding<Item?>
  public let sheet: (Item) -> Sheet

  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass

  // MARK: - Body
  public var body: some View {
    content()
      .sheetOrFullScreenCover(
        item: item,
        content: sheet,
        horizontalSizeClass: horizontalSizeClass,
        verticalSizeClass: verticalSizeClass,
      )
  }
}

// MARK: - Private method
private extension View {
  @ViewBuilder
  func sheetOrFullScreenCover<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    @ContentBuilder content: @escaping (Item) -> Content,
    horizontalSizeClass: UserInterfaceSizeClass?,
    verticalSizeClass: UserInterfaceSizeClass?,
  ) -> some View {
    // iPhone Duo で画面を開いているときは、全画面シートで表示をさせる
    if horizontalSizeClass == .regular && verticalSizeClass == .regular {
      fullScreenCover(item: item, content: content)
    } else {
      sheet(item: item, content: content)
    }
  }
}
