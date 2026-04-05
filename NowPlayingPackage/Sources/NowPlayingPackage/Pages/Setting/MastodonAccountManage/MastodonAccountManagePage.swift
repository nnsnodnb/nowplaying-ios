//
//  MastodonAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct MastodonAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    @Presents public var mastodonLogin: MastodonLoginFeature.State?
  }

  // MARK: - Action
  public enum Action {
    case addAccount
    case mastodonLogin(PresentationAction<MastodonLoginFeature.Action>)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addAccount:
        state.mastodonLogin = .init()
        return .none
      case .mastodonLogin:
        return .none
      }
    }
    .ifLet(\.$mastodonLogin, action: \.mastodonLogin) {
      MastodonLoginFeature()
    }
  }
}

public struct MastodonAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<MastodonAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    Text("")
      .toolbar(
        addAction: {
          store.send(.addAccount)
        },
      )
      .sheet(
        item: $store.scope(state: \.$mastodonLogin, action: \.mastodonLogin),
        content: { store in
          MastodonLoginPage(store: store)
        },
      )
  }
}

private extension View {
  func toolbar(addAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button(
          action: addAction,
          label: {
            Image(systemSymbol: .atBadgePlus)
          },
        )
      }
    }
  }
}

#Preview {
  MastodonAccountManagePage(
    store: .init(
      initialState: MastodonAccountManageFeature.State(),
      reducer: {
        MastodonAccountManageFeature()
      },
    ),
  )
}
