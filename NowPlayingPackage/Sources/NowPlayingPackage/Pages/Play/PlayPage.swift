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
    public var isPurchasedHideAds: Bool
    @Init(default: nil)
    public var artworkImage: UIImage?
    @Init(default: nil)
    public var songName: String?
    @Init(default: nil)
    public var artistName: String?
    @Init(default: nil)
    public var album: String?
    public var isPlaying = false
    @Init(default: nil)
    public var bannerAdUnitID: String?
    @Init(default: UIColor.black.withAlphaComponent(0.7))
    public var backgroundColor: UIColor
    @Init(default: nil)
    @Presents public var setting: SettingFeature.State?
    @Presents public var tweet: TweetFeature.State?
    @Presents public var post: PostFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case backward
    case togglePlayback
    case forward
    case showSetting
    case showPost(SocialService)
    case setting(PresentationAction<SettingFeature.Action>)
    case tweet(PresentationAction<TweetFeature.Action>)
    case post(PresentationAction<PostFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case authorizationSuccess
      case authorizationFailure(String)
      case applyNowPlayingItem(any MediaItemProtocol)
      case requestArtwork(any MediaItemProtocol)
      case applyArtwork(UIImage, UIColor)
      case changedIsPlaying(Bool)
      case captureScreen(SocialService, [TwitterAccount], [BlueskyAccount])
      case emptyPostTicket
      case emptySNSAccounts(SocialService)
      case showTweet([TwitterAccount], UIImage)
      case showPost([BlueskyAccount], UIImage)
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.adUnit)
  private var adUnit
  @Dependency(\.averageColor)
  private var averageColor
  @Dependency(\.mediaPlayer)
  private var mediaPlayer
  @Dependency(\.imageRenderer)
  private var imageRenderer
  @Dependency(\.mainQueue)
  private var mainQueue
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

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
      case let .showPost(socialService):
        switch socialService {
        case .twitter:
          return .run(
            operation: { send in
              let availablePostTicket = try await secureKeyValueStore.getAvailablePostTicket()
              if availablePostTicket.remainingFreeCount + availablePostTicket.remainingPurchasedCount == 0 {
                await send(.internalAction(.emptyPostTicket))
                return
              }
              let twitterAccounts = try await secureKeyValueStore.getTwitterAccounts()
              guard !twitterAccounts.isEmpty else {
                await send(.internalAction(.emptySNSAccounts(.twitter)))
                return
              }
              await send(.internalAction(.captureScreen(socialService, twitterAccounts, [])))
            },
          )
        case .bluesky:
          return .run(
            operation: { send in
              let blueskyAccounts = try await secureKeyValueStore.getBlueskyAccounts()
              guard !blueskyAccounts.isEmpty else {
                await send(.internalAction(.emptySNSAccounts(.bluesky)))
                return
              }
              await send(.internalAction(.captureScreen(socialService, [], blueskyAccounts)))
            },
          )
        }
      case .setting(.presented(.delegate(.hideAds))):
        state.isPurchasedHideAds = true
        return .none
      case .setting:
        return .none
      case .tweet:
        return .none
      case .post:
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
        state.songName = mediaItem.title
        state.artistName = mediaItem.artist
        state.album = mediaItem.albumTitle
        return .send(.internalAction(.requestArtwork(mediaItem)))
      case let .internalAction(.requestArtwork(mediaItem)):
        return .run(
          operation: { send in
            if let image = try await mediaPlayer.getNowPlayingArtwork(mediaItem) {
              let averageColor = try averageColor.make(image)
              await send(.internalAction(.applyArtwork(image, averageColor)))
            }
          },
        )
      case let .internalAction(.applyArtwork(image, averageColor)):
        state.artworkImage = image
        state.backgroundColor = averageColor
        return .none
      case let .internalAction(.changedIsPlaying(isPlaying)):
        state.isPlaying = isPlaying
        return .none
      case let .internalAction(.captureScreen(socialService, twitterAccounts, blueskyAccounts)):
        return .run(
          operation: { send in
            // Menuを閉じるためメインスレッドで待機する
            try await mainQueue.sleep(for: .milliseconds(300))
            let capturedImage = try await imageRenderer.image()
            switch socialService {
            case .twitter:
              await send(.internalAction(.showTweet(twitterAccounts, capturedImage)))
            case .bluesky:
              await send(.internalAction(.showPost(blueskyAccounts, capturedImage)))
            }
          },
        )
      case .internalAction(.emptyPostTicket):
        state.alert = AlertState(
          title: {
            TextState("投稿チケットがありません")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
          message: {
            TextState("左下の設定ボタンから「有料コンテンツ」を選択し広告を視聴するか投稿チケットを購入してください")
          },
        )
        return .none
      case let .internalAction(.emptySNSAccounts(socialService)):
        let name = socialService.rawValue
        state.alert = AlertState(
          title: {
            TextState("\(name)アカウントが設定されていません")
          },
          message: {
            TextState("左下の設定ボタンから「\(name)設定」→「アカウント管理」→左上のボタンから認証を行ってください")
          },
        )
        return .none
      case let .internalAction(.showTweet(twitterAccounts, capturedImage)):
        guard let songName = state.songName,
              songName != "読み込み中...",
              let artistName = state.artistName else {
          state.alert = AlertState(
            title: {
              TextState("投稿に必要な情報が取得できません")
            },
            message: {
              TextState("曲名とアーティスト名が取得できていません")
            },
          )
          return .none
        }
        state.tweet = .init(
          twitterAccounts: twitterAccounts,
          title: songName,
          artist: artistName,
          album: state.album,
          artwork: state.artworkImage,
          capturedImage: capturedImage,
        )
        return .none
      case let .internalAction(.showPost(blueskyAccounts, capturedImage)):
        guard let songName = state.songName,
              songName != "読み込み中...",
              let artistName = state.artistName else {
          state.alert = AlertState(
            title: {
              TextState("投稿に必要な情報が取得できません")
            },
            message: {
              TextState("曲名とアーティスト名が取得できていません")
            },
          )
          return .none
        }
        state.post = .init(
          blueskyAccounts: blueskyAccounts,
          title: songName,
          artist: artistName,
          album: state.album,
          artwork: state.artworkImage,
          capturedImage: capturedImage,
        )
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$setting, action: \.setting) {
      SettingFeature()
    }
    .ifLet(\.$tweet, action: \.tweet) {
      TweetFeature()
    }
    .ifLet(\.$post, action: \.post) {
      PostFeature()
    }
    .ifLet(\.$alert, action: \.alert)
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
    .background {
      Color(store.backgroundColor)
        .ignoresSafeArea(.all)
    }
    .onAppear {
      store.send(.onAppear)
    }
    .sheet(item: $store.scope(state: \.setting, action: \.setting)) { store in
      SettingPage(store: store)
    }
    .sheet(item: $store.scope(state: \.tweet, action: \.tweet)) { store in
      TweetPage(store: store)
    }
    .sheet(item: $store.scope(state: \.post, action: \.post)) { store in
      PostPage(store: store)
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
    .scaleEffect(x: store.isPlaying ? 1 : 0.8, y: store.isPlaying ? 1 : 0.8)
    .animation(.spring(response: 0.3, dampingFraction: store.isPlaying ? 0.5 : 0.6), value: store.isPlaying)
    .padding(12)
  }

  private var songInfo: some View {
    VStack(alignment: .center, spacing: 8) {
      ScrollFlowText(
        text: store.songName ?? "曲名",
        textColor: .white,
        font: .boldSystemFont(ofSize: 20)
      )
      ScrollFlowText(
        text: store.artistName ?? "アーティスト名",
        textColor: .white.withAlphaComponent(0.7),
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
          .foregroundStyle(.white)
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
          .foregroundStyle(.white)
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
          .foregroundStyle(.white)
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
    .padding(.horizontal, 16)
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
      twitterAction: {
        store.send(.showPost(.twitter))
      },
      blueskyAction: {
        store.send(.showPost(.bluesky))
      },
    )
  }

  @ViewBuilder private var bottomBanner: some View {
    if !store.isPurchasedHideAds, let adUnitID = store.bannerAdUnitID {
      PlayerBottomAdBanner(adUnitID: adUnitID)
    }
  }
}

struct PlayPage_Previews: PreviewProvider {
  static var previews: some View {
    PlayPage(
      store: .init(
        initialState: PlayFeature.State(isPurchasedHideAds: false),
        reducer: {
          PlayFeature()
        },
      ),
    )
  }
}
