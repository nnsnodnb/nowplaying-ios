//
//  BlueskyProfileRow.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import NukeUI
import SwiftUI

public struct BlueskyProfileRow: View {
  // MARK: - Properties
  public let blueskyAccount: BlueskyAccount
  public let showDefaultStar: Bool
  public var selected = false

  // MARK: - Body
  public var body: some View {
    HStack(alignment: .center, spacing: 12) {
      image
      VStack(alignment: .leading, spacing: 4) {
        if let displayName = blueskyAccount.displayName {
          Text(displayName)
            .font(.system(size: 20, weight: .semibold))
        }
        Text("@\(blueskyAccount.handle)")
          .font(.system(size: 17))
      }
      if showDefaultStar && blueskyAccount.isDefault {
        Spacer()
        defaultStar
          .padding(.trailing, 12)
      } else if selected {
        Spacer()
        selectedCheckmark
          .padding(.trailing, 12)
      }
    }
  }

  private var image: some View {
    Group {
      if let avatarImageURL = blueskyAccount.avatarImageURL {
        LazyImage(url: avatarImageURL) { state in
          if state.isLoading {
            ProgressView()
              .progressViewStyle(.circular)
          } else if let image = state.image {
            image
              .resizable()
              .scaledToFill()
              .clipShape(Circle())
          } else {
            Image(systemSymbol: .photoBadgeExclamationmark)
              .resizable()
              .scaledToFit()
              .foregroundStyle(.red)
              .padding(4)
          }
        }
      } else {
        Image(systemSymbol: .personCircleFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(Color.accentColor)
      }
    }
    .frame(width: 48, height: 48)
  }

  private var defaultStar: some View {
    Image(systemSymbol: .starFill)
      .resizable()
      .scaledToFit()
      .foregroundStyle(.yellow)
      .frame(width: 24, height: 24)
  }

  private var selectedCheckmark: some View {
    Image(systemSymbol: .checkmarkCircleFill)
      .resizable()
      .scaledToFit()
      .foregroundStyle(.white, Color.accentColor)
      .frame(width: 24, height: 24)
  }
}
