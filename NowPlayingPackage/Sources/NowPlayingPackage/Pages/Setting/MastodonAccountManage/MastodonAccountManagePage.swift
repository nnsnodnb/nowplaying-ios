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
    public var mastodonAccounts: [MastodonAccount] = []
    @Presents public var mastodonLogin: MastodonLoginFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case fetchMastodonAccounts
    case addAccount
    case changeDefaultAccount(MastodonAccount)
    case deleteMastodonAccount(IndexSet)
    case mastodonLogin(PresentationAction<MastodonLoginFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedMastodonAccounts([MastodonAccount])
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchMastodonAccounts:
        return .run(
          operation: { send in
            let mastodonAccounts = try await secureKeyValueStore.getMastodonAccounts()
            await send(.internalAction(.fetchedMastodonAccounts(mastodonAccounts)))
          },
        )
      case .addAccount:
        state.mastodonLogin = .init()
        return .none
      case let .changeDefaultAccount(mastodonAccount):
        guard !mastodonAccount.isDefault else { return .none }
        return .run(
          operation: { send in
            var mastodonAccount = mastodonAccount
            mastodonAccount.setDefault()
            try await secureKeyValueStore.updateDefaultMastodonAccount(mastodonAccount)
            await send(.fetchMastodonAccounts)
          },
        )
      case let .mastodonLogin(.presented(.delegate(.loggedIn(mastodonAccount)))):
        state.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("\(mastodonAccount.displayName) (@\(mastodonAccount.username))")
          },
        )
        return .send(.fetchMastodonAccounts)
      case let .deleteMastodonAccount(indexSet):
        return .run(
          operation: { [mastodonAccounts = state.mastodonAccounts] send in
            for mastodonAccount in indexSet.compactMap({ mastodonAccounts[safe: $0] }) {
              try await secureKeyValueStore.removeMastodonAccount(mastodonAccount)
            }
            await send(.fetchMastodonAccounts)
          },
        )
      case .mastodonLogin:
        return .none
      case let .internalAction(.fetchedMastodonAccounts(mastodonAccounts)):
        state.mastodonAccounts = mastodonAccounts
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
    list
      .navigationTitle(.accountManagement)
      .toolbar(
        addAction: {
          store.send(.addAccount)
        },
      )
      .task {
        store.send(.fetchMastodonAccounts)
      }
      .sheet(
        item: $store.scope(state: \.$mastodonLogin, action: \.mastodonLogin),
        content: { store in
          MastodonLoginPage(store: store)
        },
      )
      .alert($store.scope(state: \.$alert, action: \.alert))
      .analyticsScreen(screenName: .mastodonAccountManage)
  }

  @ViewBuilder private var list: some View {
    if store.mastodonAccounts.isEmpty {
      AccountEmptyView()
    } else {
      List {
        ForEach(store.mastodonAccounts, id: \.self) { mastodonAccount in
          mastodonAccountRow(mastodonAccount)
        }
        .onDelete(
          perform: { indexSet in
            store.send(.deleteMastodonAccount(indexSet))
          },
        )
      }
    }
  }

  private func mastodonAccountRow(_ mastodonAccount: MastodonAccount) -> some View {
    Button(
      action: {
        store.send(.changeDefaultAccount(mastodonAccount))
      },
      label: {
        MastodonProfileRow(
          mastodonAccount: mastodonAccount,
          showDefaultStar: true,
        )
        .foregroundStyle(Color.primary)
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
