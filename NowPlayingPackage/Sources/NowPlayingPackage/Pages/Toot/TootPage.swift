//
//  TootPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
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
    public var isDisablePostButton = false
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
    // TODO: @Presents public var selectMastodonAccount: SelectMastodonAccountFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case alert(PresentationAction<Alert>)

    // MARK: - Action
    public enum Alert: Equatable, Sendable {
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct TootPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<TootFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        Text("")
          .navigationTitle(.toot)
          .navigationBarTitleDisplayMode(.inline)
          .alert($store.scope(state: \.$alert, action: \.alert))
      },
    )
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
