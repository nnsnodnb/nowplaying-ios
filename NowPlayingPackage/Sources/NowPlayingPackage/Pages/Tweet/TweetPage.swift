//
//  TweetPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import Dependencies
import ImageViewer
import NukeUI
import SwiftUI

@Reducer
public struct TweetFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var twitterAccounts: [TwitterAccount]
    public let title: String
    public let artist: String
    public let album: String?
    public let artwork: UIImage?
    public let capturedImage: UIImage
    public var attachmentImage: UIImage?
    public var postableTwitterAccount: TwitterAccount?
    public var text = ""
    public var temporaryMedia: TwitterMedia?
    public var isEditing = false
    public var isDisablePostButton = false
    public var isShowPreview = false
    public var isLoading = false
    public var showSuccess = false
    @Shared(.appStorage(.twitterIsAttachImage))
    public var isAttachImage = true
    @Shared(.appStorage(.twitterWithImageType))
    public var attachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage(.twitterPostFormat))
    public var postFormat = ""
    @Presents public var selectTwitterAccount: SelectTwitterAccountFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case preparePost
    case changedText(String)
    case showSelectTwitterAccount
    case addArtwork
    case addCapturedImage
    case removeAttachmentImage
    case showPreview(Bool)
    case selectTwitterAccount(PresentationAction<SelectTwitterAccountFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case uploadImageData(TwitterOAuthToken.AccessToken, Data)
      case post(TwitterOAuthToken.AccessToken, TwitterMedia?)
      case posted
      case postFailure(String)
      case fetchTwitterAccounts
      case refreshTwitterAccounts([TwitterAccount], TwitterAccount?)
      case dismiss
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case delete
      case close
    }
  }

  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.mainQueue)
  private var mainQueue
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore
  @Dependency(\.twitterAPI)
  private var twitterAPI
  @Dependency(\.twitterOAuth)
  private var twitterOAuth

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
      case .preparePost:
        guard !state.isDisablePostButton,
              let twitterAccount = state.postableTwitterAccount else { return .none }
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let accessToken = try await twitterOAuth.getAccessToken(twitterAccount.oauthToken)
            // 有効期限内のメディアであればそのまま使用する
            if let media = state.temporaryMedia,
               !media.isExpired {
              await send(.internalAction(.post(accessToken, media)))
            } else if let attachmentImage = state.attachmentImage,
                      let imageData = attachmentImage.jpegData(compressionQuality: 0.3) {
              await send(.internalAction(.uploadImageData(accessToken, imageData)))
            } else {
              await send(.internalAction(.post(accessToken, nil)))
            }
          },
          catch: { _, send in
            await send(.internalAction(.postFailure("認証情報の取得に失敗しました")))
          },
        )
      case let .changedText(text):
        state.text = text
        state.isEditing = true
        state.isDisablePostButton = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .none
      case .showSelectTwitterAccount:
        guard state.twitterAccounts.count > 1,
              let postableTwitterAccount = state.postableTwitterAccount else {
          return .none
        }
        state.selectTwitterAccount = .init(
          twitterAccounts: state.twitterAccounts,
          selectedTwitterAccount: postableTwitterAccount,
        )
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
        state.temporaryMedia = nil
        state.isEditing = true
        return .none
      case let .showPreview(isShow):
        state.isShowPreview = isShow
        return .none
      case let .selectTwitterAccount(.presented(.delegate(.select(twitterAccount)))):
        state.postableTwitterAccount = twitterAccount
        return .none
      case .selectTwitterAccount:
        return .none
      case let .internalAction(.uploadImageData(accessToken, imageData)):
        return .run(
          operation: { send in
            let media = try await twitterAPI.uploadMedia(accessToken, imageData)
            await send(.internalAction(.post(accessToken, media)))
          },
          catch: { _, send in
            await send(.internalAction(.postFailure("画像のアップロードに失敗しました")))
          },
        )
      case let .internalAction(.post(accessToken, media)):
        state.temporaryMedia = media
        return .run(
          operation: { [text = state.text] send in
            try await twitterAPI.post(accessToken, media?.id, text)
            await send(.internalAction(.posted))
          },
          catch: { _, send in
            await send(.internalAction(.postFailure("ポストに失敗しました")))
          },
        )
      case .internalAction(.posted):
        state.isLoading = false
        state.showSuccess = true
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(500))
            await send(.internalAction(.dismiss))
          },
        )
      case let .internalAction(.postFailure(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
        return .send(.internalAction(.fetchTwitterAccounts))
      case .internalAction(.fetchTwitterAccounts):
        guard let postableTwitterAccount = state.postableTwitterAccount else { return .none }
        return .run(
          operation: { send in
            let twitterAccounts = try await secureKeyValueStore.twitterAccounts()
            let postableTwitterAccount = twitterAccounts.first(where: { $0.profile.id == postableTwitterAccount.profile.id })
            await send(.internalAction(.refreshTwitterAccounts(twitterAccounts, postableTwitterAccount)))
          },
        )
      case let .internalAction(.refreshTwitterAccounts(twitterAccounts, postableTwitterAccount)):
        state.twitterAccounts = twitterAccounts
        state.postableTwitterAccount = postableTwitterAccount
        return .none
      case .internalAction(.dismiss):
        state.showSuccess = false
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .alert(.presented(.delete)):
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .alert:
        return .none
      }
    }
    .ifLet(\.$selectTwitterAccount, action: \.selectTwitterAccount) {
      SelectTwitterAccountFeature()
    }
    .ifLet(\.$alert, action: \.alert)
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
          .navigationTitle("Xへポスト")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            disablePostButton: store.isDisablePostButton,
            cancelAction: {
              store.send(.close)
            },
            postAction: {
              store.send(.preparePost)
              isFocused = false
            },
          )
          .onAppear {
            store.send(.onAppear)
            isFocused = true
          }
          .interactiveDismissDisabled(store.isEditing)
          .alert($store.scope(state: \.alert, action: \.alert))
          .sheet(item: $store.scope(state: \.selectTwitterAccount, action: \.selectTwitterAccount)) { store in
            selectTwitterAccountPage(store: store)
          }
          .fullScreenCover(isPresented: $store.isShowPreview.sending(\.showPreview)) {
            imageViewer
          }
          .onChange(of: store.isShowPreview, initial: false) { oldValue, newValue in
            if oldValue && !newValue {
              isFocused = true
            }
          }
          .progress(store.isLoading)
          .onChange(of: store.showSuccess, initial: false) { _, newValue in
            if newValue {
              SVProgressHUD.showSuccess(withStatus: "ポストしました")
            } else {
              SVProgressHUD.dismiss()
            }
          }
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
            isFocused = false
            store.send(.showPreview(true))
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

  private func selectTwitterAccountPage(store: StoreOf<SelectTwitterAccountFeature>) -> some View {
    SelectTwitterAccountPage(store: store)
      .presentationDetents([.medium, .large])
      .presentationBackgroundInteraction(.disabled)
      .presentationBackground(.background)
  }

  private var imageViewer: some View {
    ImageViewer(
      image: .init(
        get: {
          Image(uiImage: store.attachmentImage ?? .init(systemSymbol: .xmarkCircleFill))
        },
        set: { _ in }
      ),
      viewerShown: $store.isShowPreview.sending(\.showPreview),
      closeButtonTopRight: true,
    )
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
              label: {
                Text("ポスト")
              },
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
