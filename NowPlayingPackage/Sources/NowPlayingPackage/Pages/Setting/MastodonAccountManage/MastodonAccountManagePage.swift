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
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case fetchMastodonAccount
    case addAccount
    case mastodonLogin(PresentationAction<MastodonLoginFeature.Action>)
    case alert(PresentationAction<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchMastodonAccount:
        return .none
      case .addAccount:
        state.mastodonLogin = .init()
        return .none
      case let .mastodonLogin(.presented(.delegate(.loggedIn(mastodonAccount)))):
        state.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("\(mastodonAccount.displayName) (@\(mastodonAccount.username))")
          },
        )
        // TODO: fetchMastodonAccounts
        return .none
      case .mastodonLogin:
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$mastodonLogin, action: \.mastodonLogin) {
      MastodonLoginFeature()
    }
    .ifLet(\.$alert, action: \.alert)
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
      .alert($store.scope(state: \.$alert, action: \.alert))
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
