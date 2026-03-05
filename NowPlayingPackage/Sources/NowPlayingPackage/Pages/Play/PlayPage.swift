//
//  PlayPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import ComposableArchitecture
import MemberwiseInit
import SFSafeSymbols
import SwiftUI

@Reducer
public struct PlayFeature: Sendable {
  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable {
    public var songName = "曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名"
    public var artistName = "アーティスト名アーティスト名アーティスト名"
    public var isPlaying = false
    @Init(default: nil)
    public var bannerAdUnitID: String?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case togglePlayback
    case xTwitter
    case bluesky
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        // TODO: Get adUnitID from DI client
        state.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
        return .none
      case .togglePlayback:
        state.isPlaying.toggle()
        return .none
      case .xTwitter:
        return .none
      case .bluesky:
        return .none
      }
    }
  }
}

public struct PlayPage: View {
  // MARK: - Properties
  public let store: StoreOf<PlayFeature>

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
      VStack(alignment: .center, spacing: 8) {
        bottomTools
        bottomBanner
      }
    }
    .onAppear {
      store.send(.onAppear)
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
    VStack(alignment: .center, spacing: 8) {
      ScrollFlowText(
        text: store.songName,
        textColor: .label,
        font: .boldSystemFont(ofSize: 20)
      )
      ScrollFlowText(
        text: store.artistName,
        textColor: .tertiaryLabel,
        font: .systemFont(ofSize: 17)
      )
    }
    .padding(.horizontal, 36)
  }

  private var controlButtons: some View {
    HStack(alignment: .center, spacing: 40) {
      backwardButton
      playbackButton
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
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .buttonStyle(.pressScale)
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .frame(width: 54, height: 54)
  }

  private var playbackButton: some View {
    Button(
      action: {
        store.send(.togglePlayback)
      },
      label: {
        Image(systemSymbol: store.isPlaying ? .pauseFill : .playFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .buttonStyle(.pressScale)
    .frame(width: 62, height: 62)
  }

  private var forwardButton: some View {
    Button(
      action: {
      },
      label: {
        Image(systemSymbol: .forwardFill)
          .resizable()
          .foregroundStyle(Color(UIColor.label))
      }
    )
    .buttonStyle(.pressScale)
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
    PostPlusButton(
      xTwitterAction: {
        store.send(.xTwitter)
      },
      blueskyAction: {
        store.send(.bluesky)
      },
    )
  }

  @ViewBuilder private var bottomBanner: some View {
    if let adUnitID = store.bannerAdUnitID {
      PlayerBottomAdBanner(adUnitID: adUnitID)
    }
  }
}

struct PlayPage_Previews: PreviewProvider {
  static var previews: some View {
    PlayPage(
      store: .init(
        initialState: PlayFeature.State(),
        reducer: {
          PlayFeature()
        },
      ),
    )
  }
}
