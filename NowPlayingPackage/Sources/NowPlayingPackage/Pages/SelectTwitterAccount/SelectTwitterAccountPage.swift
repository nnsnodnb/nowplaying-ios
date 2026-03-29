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

  // MARK: - Dependency
  @Dependency(\.analytics)
  private var analytics
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
        return .run(
          operation: { send in
            await analytics.logEvent(.changedPostableTwitterAccount(twitterAccount.isDefault))
            await send(.delegate(.select(twitterAccount)))
          },
        )
      case .delegate(.select):
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .delegate:
        return .none
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
    .analyticsScreen(screenName: .selectTwitterAccount)
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
        CancellationButton(
          action: closeAction,
        )
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
