//
//  TootPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
import ImageViewer
import NukeUI
import SwiftUI

@Reducer
public struct TootFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var mastodonAccounts: [MastodonAccount]
    public let title: String
    public let artist: String
    public let album: String?
    public let artwork: UIImage?
    public let capturedImage: UIImage
    public var attachmentImage: UIImage?
    public var postableMastodonAccount: MastodonAccount?
    public var text = ""
    public var isEditing = false
    public var isDisableTootButton = false
    public var isShowPreview = false
    public var isLoading = false
    public var showSuccess = false
    @Shared(.appStorage(.mastodonIsAttachImage))
    public var isAttachImage = true
    @Shared(.appStorage(.mastodonWithImageType))
    public var attachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage(.mastodonTootVisibility))
    public var tootVisibility: TootVisibilityType = .public
    @Shared(.appStorage(.mastodonPostFormat))
    public var postFormat = ""
    @Presents public var selectMastodonAccount: SelectMastodonAccountFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case toot
    case changedText(String)
    case showSelectMastodonAccount
    case addArtwork
    case addCapturedImage
    case removeAttachmentImage
    case showPreview(Bool)
    case selectMastodonAccount(PresentationAction<SelectMastodonAccountFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case tooted
      case tootFailure(String)
      case dismiss
    }

    // MARK: - Action
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
  @Dependency(\.mainQueue)
  private var mainQueue
  @Dependency(\.mastodonAPI)
  private var mastodonAPI
  @Dependency(\.mastodonOAuth)
  private var mastodonOAuth

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.postableMastodonAccount = state.mastodonAccounts.first(where: { $0.isDefault })
        state.text = state.postFormat
          .replacingOccurrences(of: "__songtitle__", with: state.title)
          .replacingOccurrences(of: "__artist__", with: state.artist)
          .replacingOccurrences(of: "__album__", with: state.album ?? String(localized: .unknownAlbum))
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
              TextState(.deleteToot)
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState(.cancel)
                },
              )
              ButtonState(
                role: .destructive,
                action: .delete,
                label: {
                  TextState(.delete)
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
      case .toot:
        guard !state.isDisableTootButton,
              let mastodonAccount = state.postableMastodonAccount else { return .none }
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let accessToken = try await mastodonOAuth.getAccessToken(mastodonAccount)
            let mediaID: MastodonMediaAttachment.ID?
            if let imageData = state.attachmentImage?.jpegData(compressionQuality: 0.3) {
              let mediaAttachment = try await mastodonAPI.uploadMedia(mastodonAccount.domainURL, accessToken, imageData)
              mediaID = mediaAttachment.id
            } else {
              mediaID = nil
            }
            try await mastodonAPI.toot(mastodonAccount.domainURL, accessToken, mediaID, state.text, state.tootVisibility)
            await send(.internalAction(.tooted))
            await analytics.logEvent(.mastodonPosted(mediaID != nil))
            await analytics.setUserProperty(.postMastodon)
          },
          catch: { _, send in
            await send(.internalAction(.tootFailure(String(localized: .failedToToot))))
          },
        )
      case let .changedText(text):
        state.text = text
        state.isEditing = true
        state.isDisableTootButton = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .none
      case .showSelectMastodonAccount:
        guard state.mastodonAccounts.count > 1,
              let postableMastodonAccount = state.postableMastodonAccount else {
          return .none
        }
        state.selectMastodonAccount = .init(
          mastodonAccounts: state.mastodonAccounts,
          selectedMastodonAccount: postableMastodonAccount,
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
      case let .selectMastodonAccount(.presented(.delegate(.select(mastodonAccount)))):
        state.postableMastodonAccount = mastodonAccount
        return .none
      case .selectMastodonAccount:
        return .none
      case .internalAction(.tooted):
        state.isLoading = false
        state.showSuccess = true
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(500))
            await send(.internalAction(.dismiss))
          },
        )
      case let .internalAction(.tootFailure(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          },
        )
        return .run(
          operation: { _ in
            await analytics.logEvent(.mastodonPostedFailure)
          },
        )
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
    .ifLet(\.$selectMastodonAccount, action: \.selectMastodonAccount) {
      SelectMastodonAccountFeature()
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct TootPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<TootFeature>

  @Environment(\.colorScheme)
  private var colorScheme

  @FocusState private var isFocused: Bool

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle(.toot)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            disableTootButton: store.isDisableTootButton,
            cancelAction: {
              store.send(.close)
            },
            tootAction: {
              store.send(.toot)
              isFocused = false
            },
          )
          .task {
            store.send(.onAppear)
            isFocused = true
          }
          .interactiveDismissDisabled(store.isEditing)
          .alert($store.scope(state: \.$alert, action: \.alert))
          .sheet(item: $store.scope(state: \.$selectMastodonAccount, action: \.selectMastodonAccount)) { store in
            selectMastodonAccountPage(store: store)
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
              SVProgressHUD.showSuccess(withStatus: String(localized: .tooted))
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
    if let mastodonAccount = store.postableMastodonAccount {
      Button(
        action: {
          store.send(.showSelectMastodonAccount)
        },
        label: {
          LazyImage(url: mastodonAccount.avatarURL) { state in
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
      .disabled(store.mastodonAccounts.count == 1)
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
            Text(.preview)
          },
        )
        Button(
          action: {
            store.send(.removeAttachmentImage)
          },
          label: {
            Text(.removeAttachedImage)
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
              Text(.artworkOnly)
            },
          )
        }
        Button(
          action: {
            store.send(.addCapturedImage)
          },
          label: {
            Text(.screenshotOfThePlaybackScreen)
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

  private func selectMastodonAccountPage(store: StoreOf<SelectMastodonAccountFeature>) -> some View {
    SelectMastodonAccountPage(store: store)
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
    disableTootButton: Bool,
    cancelAction: @escaping @MainActor () -> Void,
    tootAction: @escaping @MainActor () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CancellationButton(
          action: cancelAction,
        )
      }
      ToolbarItem(placement: .confirmationAction) {
        ConfirmationButton(
          action: tootAction,
          title: String(localized: .toot),
        )
        .disabled(disableTootButton)
      }
    }
  }
}

#Preview {
  TootPage(
    store: .init(
      initialState: TootFeature.State(
        mastodonAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
      ),
      reducer: {
        TootFeature()
      },
    ),
  )
}
