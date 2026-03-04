//
//  PlayPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import SFSafeSymbols
import SwiftUI

public struct PlayPage: View {
  // MARK: - Body
  public var body: some View {
    VStack(alignment: .center, spacing: 40) {
      Spacer()
      VStack(alignment: .center, spacing: 24) {
        artworkImage
        songInfo
      }
      controlButtons
      Spacer()
      bottomTools
    }
  }

  private var artworkImage: some View {
    Image(systemSymbol: .musicQuarternote3)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .padding(40)
      .background {
        RoundedRectangle(cornerRadius: 16)
          .aspectRatio(1, contentMode: .fit)
          .foregroundStyle(.clear)
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  private var songInfo: some View {
    VStack(alignment: .center, spacing: 16) {
      Text("曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名")
        .font(.system(size: 20, weight: .bold))
        .multilineTextAlignment(.center)
      Text("アーティスト名アーティスト名アーティスト名")
    }
    .lineLimit(1)
    .padding(.horizontal, 36)
  }

  private var controlButtons: some View {
    HStack(alignment: .center, spacing: 40) {
      backwardButton
      playPauseButton
      forwardButton
    }
  }

  private var backwardButton: some View {
    Button(
      action: {
      },
      label: {
        Image(systemSymbol: .backwardFill)
          .resizable()
          .frame(width: .infinity, height: .infinity)
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .frame(width: 54, height: 54)
  }

  private var playPauseButton: some View {
    Button(
      action: {
      },
      label: {
        Image(systemSymbol: .playFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: .infinity, height: .infinity)
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .frame(width: 62, height: 62)
  }

  private var forwardButton: some View {
    Button(
      action: {
      },
      label: {
        Image(systemSymbol: .forwardFill)
          .resizable()
          .frame(width: .infinity, height: .infinity)
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .frame(width: 54, height: 54)
  }

  private var bottomTools: some View {
    HStack(alignment: .center, spacing: 0) {
      settingButton
      Spacer()
      postButton
    }
    .padding(.horizontal, 36)
    .frame(height: 56)
  }

  private var settingButton: some View {
    Button(
      action: {
      },
      label: {
        Image(systemSymbol: .gear)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(8)
          .frame(width: .infinity, height: .infinity)
          .foregroundStyle(.gray)
      },
    )
    .shadow(color: .black.opacity(0.4), radius: 0.8)
    .modifier {
      if #available(iOS 26.0, *) {
        $0.glassEffect(.regular.interactive())
      }
    }
  }

  private var postButton: some View {
    Menu(
      content: {
//        Button(
//          action: {
//          },
//          label: {
//            Text("Bluesky")
//          },
//        )
        Button(
          action: {
          },
          label: {
            Text("Twitter")
          },
        )
      },
      label: {
        Image(systemSymbol: .plus)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(12)
          .frame(width: .infinity, height: .infinity)
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
  PlayPage()
}
