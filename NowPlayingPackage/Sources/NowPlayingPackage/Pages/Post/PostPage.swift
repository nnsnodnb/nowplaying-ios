//
//  PostPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
import ImageViewer
import NukeUI
import SwiftUI

@Reducer
public struct PostFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var blueskyAccounts: [BlueskyAccount]
    public let title: String
    public let artist: String
    public let album: String?
    public let artwork: UIImage?
    public let capturedImage: UIImage
    public var attachmentImage: UIImage?
    public var postableBlueskyAccount: BlueskyAccount?
    public var text = ""
    public var isEditing = false
    public var isDisablePostButton = false
    public var isShowPreview = false
    public var isLoading = false
    public var showSuccess = false
    @Shared(.appStorage(.blueskyIsAttachImage))
    public var isAttachImage = true
    @Shared(.appStorage(.blueskyWithImageType))
    public var attachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage(.blueskyPostFormat))
    public var postFormat = ""
    @Presents public var selectBlueskyAccount: SelectBlueskyAccountFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case post
    case changedText(String)
    case showSelectBlueskyAccount
    case addArtwork
    case addCapturedImage
    case removeAttachmentImage
    case showPreview(Bool)
    case selectBlueskyAccount(PresentationAction<SelectBlueskyAccountFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case posted
      case postFailure(String)
      case dismiss
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
      case delete
    }
  }

  // MARK: - Dependency
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.blueskyAPI)
  private var blueskyAPI
  @Dependency(\.mainQueue)
  private var mainQueue

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.postableBlueskyAccount = state.blueskyAccounts.first(where: { $0.isDefault })
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
        guard !state.isDisablePostButton,
              let blueskyAccount = state.postableBlueskyAccount else { return .none }
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let imageData = state.attachmentImage?.jpegData(compressionQuality: 0.3)
            try await blueskyAPI.createPostRecord(blueskyAccount, state.text, imageData)
            await send(.internalAction(.posted))
            await analytics.logEvent(.blueskyPosted(imageData != nil))
            await analytics.setUserProperty(.postBluesky)
          },
          catch: { _, send in
            await send(.internalAction(.postFailure("ポストに失敗しました")))
          },
        )
      case let .changedText(text):
        state.text = text
        state.isEditing = true
        state.isDisablePostButton = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .none
      case .showSelectBlueskyAccount:
        guard state.blueskyAccounts.count > 1,
              let postableBlueskyAccount = state.postableBlueskyAccount else {
          return .none
        }
        state.selectBlueskyAccount = .init(
          blueskyAccounts: state.blueskyAccounts,
          selectedBlueskyAccount: postableBlueskyAccount,
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
        state.isEditing = true
        return .none
      case let .showPreview(isShow):
        state.isShowPreview = isShow
        return .none
      case let .selectBlueskyAccount(.presented(.delegate(.select(blueskyAccount)))):
        state.postableBlueskyAccount = blueskyAccount
        return .none
      case .selectBlueskyAccount:
        return .none
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
        return .none
      case .internalAction(.dismiss):
        state.showSuccess = false
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .internalAction:
        return .none
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
    .ifLet(\.$selectBlueskyAccount, action: \.selectBlueskyAccount) {
      SelectBlueskyAccountFeature()
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct PostPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PostFeature>

  @Environment(\.colorScheme)
  private var colorScheme

  @FocusState private var isFocused: Bool

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle("Blueskyへポスト")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            disablePostButton: false,
            cancelAction: {
              store.send(.close)
            },
            postAction: {
              store.send(.post)
              isFocused = false
            },
          )
          .onAppear {
            store.send(.onAppear)
            isFocused = true
          }
          .interactiveDismissDisabled(store.isEditing)
          .alert($store.scope(state: \.alert, action: \.alert))
          .sheet(item: $store.scope(state: \.selectBlueskyAccount, action: \.selectBlueskyAccount)) { store in
            selectBlueskyAccountPage(store: store)
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
    .analyticsScreen(
      screenName: .post,
      extraParameters: [
        "account_count": store.blueskyAccounts.count,
      ],
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
    if let blueskyAccount = store.postableBlueskyAccount {
      Button(
        action: {
          store.send(.showSelectBlueskyAccount)
        },
        label: {
          LazyImage(url: blueskyAccount.avatarImageURL) { state in
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
      .disabled(store.blueskyAccounts.count == 1)
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

  private func selectBlueskyAccountPage(store: StoreOf<SelectBlueskyAccountFeature>) -> some View {
    SelectBlueskyAccountPage(store: store)
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
    cancelAction: @escaping @MainActor () -> Void,
    postAction: @escaping @MainActor () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CancellationButton(
          action: cancelAction,
        )
      }
      ToolbarItem(placement: .confirmationAction) {
        ConfirmationButton(
          action: postAction,
          title: "ポスト",
        )
        .disabled(disablePostButton)
      }
    }
  }
}

#Preview {
  PostPage(
    store: .init(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: "アルバム",
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        PostFeature()
      },
    ),
  )
}
