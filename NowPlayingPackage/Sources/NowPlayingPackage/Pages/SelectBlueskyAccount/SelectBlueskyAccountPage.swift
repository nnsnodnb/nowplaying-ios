//
//  SelectBlueskyAccountPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/21.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SelectBlueskyAccountFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public let blueskyAccounts: [BlueskyAccount]
    public let selectedBlueskyAccount: BlueskyAccount
  }

  // MARK: - Action
  public enum Action {
    case close
    case select(BlueskyAccount)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case select(BlueskyAccount)
    }
  }

  // MARK: - Dependency
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
      case let .select(blueskyAccount):
        return .send(.delegate(.select(blueskyAccount)))
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

public struct SelectBlueskyAccountPage: View {
  // MARK: - Properties
  public let store: StoreOf<SelectBlueskyAccountFeature>

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
      ForEach(store.blueskyAccounts, id: \.id) { blueskyAccount in
        row(blueskyAccount: blueskyAccount)
      }
    }
    .listStyle(.insetGrouped)
  }

  private func row(blueskyAccount: BlueskyAccount) -> some View {
    Button(
      action: {
        store.send(.select(blueskyAccount))
      },
      label: {
        BlueskyProfileRow(
          blueskyAccount: blueskyAccount,
          showDefaultStar: false,
          selected: store.selectedBlueskyAccount == blueskyAccount,
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

struct SelectBlueskyAccountPage_Previews: PreviewProvider {
  static var previews: some View {
    SelectBlueskyAccountPage(
      store: .init(
        initialState: SelectBlueskyAccountFeature.State(
          blueskyAccounts: [],
          selectedBlueskyAccount: .init(
            id: .init("mock_did"),
            handle: "example.bsky.social",
            displayName: "Example",
            avatarImageURL: nil,
          ),
        ),
        reducer: {
          SelectBlueskyAccountFeature()
        },
      ),
    )
  }
}
