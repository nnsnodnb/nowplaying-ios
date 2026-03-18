//
//  SelectTwitterAccountPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SelectTwitterAccountFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public let twitterAccounts: [TwitterAccount]
    public let selectedTwitterAccount: TwitterAccount
  }

  // MARK: - Action
  public enum Action {
    case close
    case select(TwitterAccount)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case select(TwitterAccount)
    }
  }

  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .close:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case let .select(twitterAccount):
        return .send(.delegate(.select(twitterAccount)))
      case .delegate:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      }
    }
  }
}

public struct SelectTwitterAccountPage: View {
  // MARK: - Properties
  public let store: StoreOf<SelectTwitterAccountFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        list
          .navigationTitle("アカウントを選択")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            closeAction: {
              store.send(.close)
            },
          )
      },
    )
  }

  private var list: some View {
    List {
      ForEach(store.twitterAccounts, id: \.profile.id) { twitterAccount in
        row(twitterAccount: twitterAccount)
      }
    }
    .listStyle(.insetGrouped)
  }

  private func row(twitterAccount: TwitterAccount) -> some View {
    Button(
      action: {
        store.send(.select(twitterAccount))
      },
      label: {
        TwitterProfileRow(
          twitterAccount: twitterAccount,
          showDefaultStar: false,
          selected: store.selectedTwitterAccount == twitterAccount,
        )
        .foregroundStyle(Color.primary)
      },
    )
  }
}

private extension View {
  func toolbar(closeAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        if #available(iOS 26.0, *) {
          Button(role: .close, action: closeAction)
        } else {
          Button(
            action: closeAction,
            label: {
              Image(systemSymbol: .xmark)
            },
          )
        }
      }
    }
  }
}

struct SelectTwitterAccountPage_Previews: PreviewProvider {
  static var previews: some View {
    SelectTwitterAccountPage(
      store: .init(
        initialState: SelectTwitterAccountFeature.State(
          twitterAccounts: [],
          selectedTwitterAccount: TwitterAccount(
            oauthToken: .init(
              expiresIn: 7200,
              accessToken: .init("mock_access_token"),
              refreshToken: .init("mock_refresh_token"),
              scope: "users.read",
              expiresAt: .init(timeInterval: 7200, since: .init())
            ),
            profile: .init(
              id: .init("1137201750"),
              name: "小泉ひやかし🌻",
              username: "nnsnodnb",
              profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq_normal.jpg")!,
            ),
            isDefault: true,
          )
        ),
        reducer: {
          SelectTwitterAccountFeature()
        },
      ),
    )
  }
}
