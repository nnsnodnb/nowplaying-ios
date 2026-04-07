//
//  SelectMastodonAccountPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SelectMastodonAccountFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public let mastodonAccounts: [MastodonAccount]
    public let selectedMastodonAccount: MastodonAccount
  }

  // MARK: - Action
  public enum Action {
    case close
    case select(MastodonAccount)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case select(MastodonAccount)
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
      case let .select(mastodonAccount):
        return .run(
          operation: { send in
            await send(.delegate(.select(mastodonAccount)))
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

public struct SelectMastodonAccountPage: View {
  // MARK: - Properties
  public let store: StoreOf<SelectMastodonAccountFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        list
          .navigationTitle(.selectAnAccount)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            closeAction: {
              store.send(.close)
            },
          )
      },
    )
    .analyticsScreen(screenName: .selectMastodonAccount)
  }

  private var list: some View {
    List {
      ForEach(store.mastodonAccounts, id: \.id) { mastodonAccount in
        row(mastodonAccount: mastodonAccount)
      }
    }
    .listStyle(.insetGrouped)
  }

  private func row(mastodonAccount: MastodonAccount) -> some View {
    Button(
      action: {
        store.send(.select(mastodonAccount))
      },
      label: {
        MastodonProfileRow(
          mastodonAccount: mastodonAccount,
          showDefaultStar: false,
          selected: store.selectedMastodonAccount == mastodonAccount,
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

#Preview {
  SelectMastodonAccountPage(
    store: .init(
      initialState: SelectMastodonAccountFeature.State(
        mastodonAccounts: [],
        selectedMastodonAccount: .init(
          id: .init("stub_id"),
          domainURL: URL(string: "https://example.com")!,
          displayName: "表示名",
          username: "sample",
          avatarURL: URL(string: "https://example.com/image.jpeg")!,
        )
      ),
      reducer: {
        SelectMastodonAccountFeature()
      },
    ),
  )
}
