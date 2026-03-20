//
//  PostPlusButton.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import SwiftUI

public struct PostPlusButton: View {
  // MARK: - Properties
  public let twitterAction: () -> Void
  public let blueskyAction: () -> Void

  public var body: some View {
    Menu(
      content: {
        Button(
          action: blueskyAction,
          label: {
            Label(
              title: {
                Text("Bluesky")
              },
              icon: {
                Image(.icBlueskyPadding)
              },
            )
          },
        )
        Button(
          action: twitterAction,
          label: {
            Label(
              title: {
                Text("X")
              },
              icon: {
                Image(.icXTwitterPadding)
              },
            )
          },
        )
      },
      label: {
        Image(systemSymbol: .plus)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(12)
          .foregroundStyle(.white)
          .shadow(color: .black.opacity(0.4), radius: 0.8)
          .background(.blue)
          .clipShape(Circle())
      }
    )
    .modifier { view in
      if #available(iOS 26.0, *) {
        view.glassEffect(.regular.interactive())
      }
    }
  }
}

#Preview {
  PostPlusButton(
    twitterAction: {},
    blueskyAction: {}
  )
}
