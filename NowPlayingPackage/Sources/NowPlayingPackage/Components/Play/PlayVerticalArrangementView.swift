//
//  PlayVerticalArrangementView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/08.
//

import SwiftUI

@available(iOS 27.1, *)
public struct PlayVerticalArrangementView<
  Artwork: View,
  SongInfo: View,
  ControlButtons: View,
  BottomTools: View,
>: View {
  // MARK: - Properties
  public let artwork: @MainActor () -> Artwork
  public let songInfo: @MainActor () -> SongInfo
  public let controlButtons: @MainActor () -> ControlButtons
  public let bottomTools: @MainActor () -> BottomTools

  // MARK: - Body
  public var body: some View {
    ArrangementView(
      primary: {
        VStack(alignment: .center, spacing: 16) {
          artwork()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      },
      secondary: {
        VStack(alignment: .center, spacing: 28) {
          Spacer()
          songInfo()
          controlButtons()
        }
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .bottom)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
          bottomTools()
        }
      },
    )
    .arrangementViewStyle(.split.axes(.vertical))
  }
}
