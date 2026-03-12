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
    @Init(default: nil)
    public var artworkImage: UIImage?
    public var songName = "曲名"
    public var artistName = "アーティスト名"
    public var isPlaying = false
    @Init(default: nil)
    public var bannerAdUnitID: String?
    @Presents public var setting: SettingFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case backward
    case togglePlayback
    case forward
    case showSetting
    case xTwitter
    case bluesky
    case setting(PresentationAction<SettingFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case authorizationSuccess
      case authorizationFailure(String)
      case applyNowPlayingItem(any MediaItemProtocol)
      case requestArtwork(any MediaItemProtocol)
      case applyArtwork(UIImage)
      case changedIsPlaying(Bool)
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
    }
  }

  @Dependency(\.adUnit)
  private var adUnit
  @Dependency(\.mediaPlayer)
  private var mediaPlayer

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.bannerAdUnitID = adUnit.playerBottomBannerAdUnitID()
        return .run(
          operation: { send in
            try await mediaPlayer.requestAuthorization()
            await send(.internalAction(.authorizationSuccess))
          },
          catch: { error, send in
            guard let error = error as? MediaPlayerClient.Error else { return }
            switch error {
            case .denied:
              await send(.internalAction(.authorizationFailure("ミュージックライブラリへのアクセスが拒否されました")))
            case .restricted:
              await send(.internalAction(.authorizationFailure("ミュージックライブラリへのアクセスが制限されています")))
            }
          },
        )
      case .backward:
        return .run(
          operation: { _ in
            try await mediaPlayer.backward()
          },
        )
      case .togglePlayback:
        return .run(
          operation: { _ in
            try await mediaPlayer.playback()
          },
        )
      case .forward:
        return .run(
          operation: { _ in
            try await mediaPlayer.forward()
          },
        )
      case .showSetting:
        state.setting = .init()
        return .none
      case .xTwitter:
        return .none
      case .bluesky:
        return .none
      case .setting:
        return .none
      case .internalAction(.authorizationSuccess):
        state.songName = "読み込み中..."
        state.artistName = ""
        return .merge(
          .run(
            operation: { send in
              for await nowPlayingItem in try await mediaPlayer.nowPlayingItem() {
                guard let nowPlayingItem else { continue }
                await send(.internalAction(.applyNowPlayingItem(nowPlayingItem)))
              }
            },
          ),
          .run(
            operation: { send in
              for await isPlaying in try await mediaPlayer.playbackState() {
                await send(.internalAction(.changedIsPlaying(isPlaying)))
              }
            },
          )
        )
      case let .internalAction(.authorizationFailure(title)):
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
        return .none
      case let .internalAction(.applyNowPlayingItem(mediaItem)):
        state.songName = mediaItem.title ?? "不明な曲名"
        state.artistName = mediaItem.artist ?? "不明なアーティスト"
        return .send(.internalAction(.requestArtwork(mediaItem)))
      case let .internalAction(.requestArtwork(mediaItem)):
        return .run(
          operation: { send in
            if let image = try await mediaPlayer.getNowPlayingArtwork(mediaItem) {
              await send(.internalAction(.applyArtwork(image)))
            }
          },
        )
      case let .internalAction(.applyArtwork(image)):
        state.artworkImage = image
        return .none
      case let .internalAction(.changedIsPlaying(isPlaying)):
        state.isPlaying = isPlaying
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$setting, action: \.setting) {
      SettingFeature()
    }
  }
}

public struct PlayPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PlayFeature>
  @Environment(\.colorScheme)
  private var colorScheme

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
    .sheet(item: $store.scope(state: \.setting, action: \.setting)) { store in
      SettingPage(store: store)
    }
    .alert($store.scope(state: \.alert, action: \.alert))
  }

  private var artworkImage: some View {
    Group {
      if let artworkImage = store.artworkImage {
        Image(uiImage: artworkImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.4), radius: 8)
      } else {
        Image(systemSymbol: .musicQuarternote3)
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
    }
    .scaleEffect(x: store.isPlaying ? 1 : 0.85, y: store.isPlaying ? 1 : 0.85)
    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: store.isPlaying)
    .padding(40)
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
        textColor: .secondaryLabel,
        font: .systemFont(ofSize: 17, weight: .semibold)
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
        store.send(.backward)
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
        store.send(.forward)
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
        store.send(.showSetting)
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
