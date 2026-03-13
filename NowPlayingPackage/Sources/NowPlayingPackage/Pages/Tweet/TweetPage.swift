//
//  TweetPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import Dependencies
import NukeUI
import SwiftUI

@Reducer
public struct TweetFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let twitterAccounts: [TwitterAccount]
    public let title: String
    public let artist: String
    public let album: String?
    public let artwork: UIImage?
    public let capturedImage: UIImage
    public var attachmentImage: UIImage?
    public var postableTwitterAccount: TwitterAccount?
    public var text = ""
    public var isEditing = false
    public var isDisablePostButton = false
    @Shared(.appStorage("is_twitter_attach_image"))
    public var isAttachImage = true
    @Shared(.appStorage("tweet_with_image_type"))
    public var attachImageType: TwitterSettingFeature.State.AttachImageType = .onlyArtwork
    @Shared(.appStorage("tweet_format"))
    public var postFormat = ""
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case post
    case changedText(String)
    case showSelectTwitterAccount
    case addArtwork
    case addCapturedImage
    case removeAttachmentImage
    case alert(PresentationAction<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case delete
    }
  }

  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.postableTwitterAccount = state.twitterAccounts.first(where: { $0.isDefault })
        state.text = state.postFormat
          .replacingOccurrences(of: "__songtitle__", with: state.title)
          .replacingOccurrences(of: "__artist__", with: state.artist)
          .replacingOccurrences(of: "__album__", with: state.album ?? "不明なアルバム")
        guard state.isAttachImage else { return .none }
        switch state.attachImageType {
        case .onlyArtwork:
          state.attachmentImage = state.artwork
        case .screenShot:
          state.attachmentImage = state.capturedImage
        }
        return .none
      case .close:
        if state.isEditing {
          state.alert = AlertState(
            title: {
              TextState("ポストを削除します")
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("キャンセル")
                },
              )
              ButtonState(
                role: .destructive,
                action: .delete,
                label: {
                  TextState("削除")
                },
              )
            },
          )
          return .none
        }
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .post:
        guard !state.isDisablePostButton else { return .none }
        // TODO: 投稿
        return .none
      case let .changedText(text):
        state.text = text
        state.isEditing = true
        state.isDisablePostButton = text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .isEmpty
        return .none
      case .showSelectTwitterAccount:
        guard state.twitterAccounts.count > 1 else { return .none }
        // TODO: 選択画面に遷移
        return .none
      case .addArtwork:
        guard let artwork = state.artwork else { return .none }
        state.attachmentImage = artwork
        state.isEditing = true
        return .none
      case .addCapturedImage:
        state.attachmentImage = state.capturedImage
        state.isEditing = true
        return .none
      case .removeAttachmentImage:
        state.attachmentImage = nil
        return .none
      case .alert(.presented(.delete)):
        state.alert = nil
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .alert:
        state.alert = nil
        return .none
      }
    }
  }
}

public struct TweetPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<TweetFeature>

  @Environment(\.colorScheme)
  private var colorScheme

  @FocusState private var isFocused: Bool

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle("ポストを作成")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            disablePostButton: store.isDisablePostButton,
            cancelAction: {
              store.send(.close)
            },
            postAction: {
              store.send(.post)
            },
          )
          .onAppear {
            store.send(.onAppear)
            isFocused = true
          }
          .interactiveDismissDisabled(store.isEditing)
          .alert($store.scope(state: \.alert, action: \.alert))
      },
    )
  }

  private var form: some View {
    Form {
      section
    }
    .formStyle(.columns)
    .frame(maxHeight: .infinity, alignment: .top)
  }

  private var section: some View {
    Section {
      HStack(alignment: .top, spacing: 8) {
        VStack(alignment: .center, spacing: 12) {
          iconButton
          attachmentImage
        }
        editor
      }
      .padding(8)
      .frame(alignment: .top)
    }
  }

  @ViewBuilder private var iconButton: some View {
    if let twitterAccount = store.postableTwitterAccount {
      Button(
        action: {
          store.send(.showSelectTwitterAccount)
        },
        label: {
          LazyImage(url: twitterAccount.profile.profileImageURL) { state in
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
        },
      )
      .frame(width: 54, height: 54)
      .clipShape(Circle())
      .disabled(store.twitterAccounts.count == 1)
    }
  }

  @ViewBuilder private var attachmentImage: some View {
    if let attachmentImage = store.attachmentImage {
      attachmentImageMenu(image: attachmentImage)
    } else {
      addAttachmentMenu
    }
  }

  private var editor: some View {
    TextEditor(
      text: $store.text.sending(\.changedText),
    )
    .focused($isFocused)
  }

  private func attachmentImageMenu(image: UIImage) -> some View {
    Menu(
      content: {
        Button(
          action: {
            // TODO: プレビュー
          },
          label: {
            Text("プレビュー")
          },
        )
        Button(
          action: {
            store.send(.removeAttachmentImage)
          },
          label: {
            Text("添付画像を削除")
          },
        )
      },
      label: {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .shadow(color: colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.4), radius: 4)
      },
    )
    .frame(width: 54, height: 54)
  }

  private var addAttachmentMenu: some View {
    Menu(
      content: {
        if store.artwork != nil {
          Button(
            action: {
              store.send(.addArtwork)
            },
            label: {
              Text("アートワークのみ")
            },
          )
        }
        Button(
          action: {
            store.send(.addCapturedImage)
          },
          label: {
            Text("再生画面のスクリーンショット")
          },
        )
      },
      label: {
        Image(systemSymbol: .photoBadgePlus)
          .resizable()
          .scaledToFit()
          .foregroundStyle(Color.accentColor)
          .padding(8)
      },
    )
    .frame(width: 54, height: 54)
  }
}

private extension View {
  func toolbar(
    disablePostButton: Bool,
    cancelAction: @escaping () -> Void,
    postAction: @escaping () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        if #available(iOS 26.0, *) {
          Button(
            role: .close,
            action: cancelAction,
          )
        } else {
          Button(
            action: cancelAction,
            label: {
              Image(systemSymbol: .xmark)
            },
          )
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Group {
          if #available(iOS 26.0, *) {
            Button(
              role: .confirm,
              action: postAction,
            )
          } else {
            Button(
              action: postAction,
              label: {
                Text("ポスト")
              },
            )
          }
        }
        .disabled(disablePostButton)
      }
    }
  }
}

struct TweetPage_Previews: PreviewProvider {
  static var previews: some View {
    TweetPage(
      store: .init(
        initialState: TweetFeature.State(
          twitterAccounts: [],
          title: "タイトル",
          artist: "アーティスト",
          album: "アルバム名",
          artwork: nil,
          capturedImage: .init()
        ),
        reducer: {
          TweetFeature()
        },
      ),
    )
  }
}
