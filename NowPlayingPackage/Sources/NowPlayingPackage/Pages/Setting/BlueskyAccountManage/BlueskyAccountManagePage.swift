//
//  BlueskyAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import CommonModule
import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct BlueskyAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var blueskyAccounts: [BlueskyAccount] = []
    public var isRefreshing = false
    @Presents public var blueskyLogin: BlueskyLoginFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?
    @Shared(.appStorage(.blueskyLegacyAccountsMissingAlert))
    public var blueskyLegacyAccountsMissingAlert = false
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case fetchBlueskyAccounts
    case refreshAccounts
    case addAccount
    case changeDefaultAccount(BlueskyAccount)
    case deleteBlueskyAccount(IndexSet)
    case blueskyLogin(PresentationAction<BlueskyLoginFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case showSorryAlertForLegacyIfNeeded(Bool)
      case fetchedBlueskyAccounts([BlueskyAccount])
      case updatedBlueskyAccounts
      case failedUpdateBlueskyAccounts
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case reset
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.blueskyAPI)
  private var blueskyAPI
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        // アラートを表示したことがなければチェックをする
        guard !state.blueskyLegacyAccountsMissingAlert else { return .none }
        return .run(
          operation: { send in
            // レガシーアカウントがなければ終了
            let hasAccounts = try await secureKeyValueStore.hasLegacyBlueskyAccounts()
            await send(.internalAction(.showSorryAlertForLegacyIfNeeded(hasAccounts)))
          },
        )
      case .fetchBlueskyAccounts:
        return .run(
          operation: { send in
            let blueskyAccounts = try await secureKeyValueStore.getBlueskyAccounts()
            await send(.internalAction(.fetchedBlueskyAccounts(blueskyAccounts)))
          },
        )
      case .refreshAccounts:
        guard !state.blueskyAccounts.isEmpty else { return .none }
        state.isRefreshing = true
        return .run(
          operation: { [state] send in
            let blueskyAccounts: [BlueskyAccount] = try await withThrowingTaskGroup(of: (Int, BlueskyAccount?).self) { group in
              for (index, blueskyAccount) in state.blueskyAccounts.enumerated() {
                group.addTask {
                  guard let identity = try await secureKeyValueStore.getBlueskyAccountIdentity(blueskyAccount.id) else {
                    return (index, nil)
                  }
                  var newBlueskyAccount = try await blueskyAPI.getUserProfile(blueskyAccount.handle, identity)
                  newBlueskyAccount.setDefault(blueskyAccount.isDefault)
                  return (index, newBlueskyAccount)
                }
              }

              var results: [BlueskyAccount?] = .init(repeating: nil, count: state.blueskyAccounts.count)
              for try await (index, blueskyAccount) in group {
                results[index] = blueskyAccount
              }
              return results.compactMap { $0 }
            }
            try await secureKeyValueStore.setBlueskyAccounts(blueskyAccounts)
            await send(.internalAction(.updatedBlueskyAccounts))
          },
          catch: { _, send in
            await send(.internalAction(.failedUpdateBlueskyAccounts))
          },
        )
      case .addAccount:
        state.blueskyLogin = .init()
        return .none
      case let .changeDefaultAccount(blueskyAccount):
        guard !blueskyAccount.isDefault else { return .none }
        return .run(
          operation: { send in
            var blueskyAccount = blueskyAccount
            blueskyAccount.setDefault()
            try await secureKeyValueStore.updateDefaultBlueskyAccount(blueskyAccount)
            await send(.fetchBlueskyAccounts)
          },
        )
      case let .deleteBlueskyAccount(indexSet):
        return .run(
          operation: { [blueskyAccounts = state.blueskyAccounts] send in
            for blueskyAccount in indexSet.compactMap({ blueskyAccounts[safe: $0] }) {
              try await secureKeyValueStore.removeBlueskyAccount(blueskyAccount)
            }
            await send(.fetchBlueskyAccounts)
          },
        )
      case let .blueskyLogin(.presented(.delegate(.loggedIn(blueskyAccount)))):
        let message: String
        if let displayName = blueskyAccount.displayName {
          message = "\(displayName) (@\(blueskyAccount.handle))"
        } else {
          message = "@\(blueskyAccount.handle)"
        }
        state.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState(message)
          },
        )
        return .send(.fetchBlueskyAccounts)
      case .blueskyLogin:
        return .none
      case let .internalAction(.showSorryAlertForLegacyIfNeeded(hasAccounts)):
        defer {
          state.$blueskyLegacyAccountsMissingAlert.withLock { $0 = true }
        }
        guard hasAccounts else { return .none }
        state.alert = AlertState(
          title: {
            TextState(.blueskyAccountsMissingAlertTitle)
          },
          actions: {
            ButtonState(
              action: .reset,
              label: {
                TextState(.okay)
              },
            )
          },
          message: {
            TextState(.blueskyAccountsMissingAlertMessage)
          },
        )
        return .none
      case let .internalAction(.fetchedBlueskyAccounts(blueskyAccounts)):
        state.blueskyAccounts = blueskyAccounts
        return .run(
          operation: { _ in
            await analytics.setUserProperty(.blueskyAccountsCount(blueskyAccounts.count + 1))
          },
        )
      case .internalAction(.updatedBlueskyAccounts):
        state.isRefreshing = false
        return .send(.fetchBlueskyAccounts)
      case .internalAction(.failedUpdateBlueskyAccounts):
        state.isRefreshing = false
        state.alert = AlertState(
          title: {
            TextState(.failedToUpdateProfileInformation)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          }
        )
        return .none
      case .internalAction:
        return .none
      case .alert(.presented(.reset)):
        return .run(
          operation: { send in
            try await secureKeyValueStore.setBlueskyAccounts([])
            await send(.fetchBlueskyAccounts)
          },
        )
      case .alert:
        return .none
      }
    }
    .ifLet(\.$blueskyLogin, action: \.blueskyLogin) {
      BlueskyLoginFeature()
    }
    .ifLet(\.alert, action: \.alert)
  }
}

public struct BlueskyAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskyAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(.accountManagement)
      .navigationScrollEdgeEffectSoft()
      .toolbar(
        existAccounts: !store.blueskyAccounts.isEmpty,
        isRefreshing: store.isRefreshing,
        refreshable: {
          store.send(.refreshAccounts)
        },
        addAction: {
          store.send(.addAccount)
        },
      )
      .task {
        store.send(.onAppear)
        store.send(.fetchBlueskyAccounts)
      }
      .sheet(
        item: $store.scope(\.blueskyLogin, action: \.blueskyLogin),
        content: { store in
          BlueskyLoginPage(store: store)
        },
      )
      .alert($store.scope(\.alert, action: \.alert))
      .analyticsScreen(screenName: .blueskyAccountManage)
  }

  @ViewBuilder private var list: some View {
    if store.blueskyAccounts.isEmpty {
      AccountEmptyView()
    } else {
      List {
        ForEach(store.blueskyAccounts, id: \.self) { blueskyAccount in
          blueskyAccountRow(blueskyAccount)
        }
        .onDelete(
          perform: { indexSet in
             store.send(.deleteBlueskyAccount(indexSet))
          },
        )
      }
    }
  }

  private func blueskyAccountRow(_ blueskyAccount: BlueskyAccount) -> some View {
    Button(
      action: {
         store.send(.changeDefaultAccount(blueskyAccount))
      },
      label: {
        BlueskyProfileRow(
          blueskyAccount: blueskyAccount,
          showDefaultStar: true,
        )
        .foregroundStyle(Color.primary)
      },
    )
  }
}

private extension View {
  func toolbar(
    existAccounts: Bool,
    isRefreshing: Bool,
    refreshable: @escaping @MainActor () -> Void,
    addAction: @escaping @MainActor () -> Void,
  ) -> some View {
    toolbar {
      if existAccounts {
        ToolbarItem {
          if isRefreshing {
            Image(systemSymbol: .arrowTrianglehead2ClockwiseRotate90)
              .symbolEffect(.rotate.clockwise.byLayer, options: .repeat(.continuous))
          } else {
            Button(
              action: refreshable,
              label: {
                Image(systemSymbol: .arrowTrianglehead2ClockwiseRotate90)
              },
            )
          }
        }
        if #available(iOS 26.0, *) {
          ToolbarSpacer(.fixed)
        }
      }
      ToolbarItem {
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
  NavigationStack(
    root: {
      BlueskyAccountManagePage(
        store: .init(
          initialState: BlueskyAccountManageFeature.State(),
          reducer: {
            BlueskyAccountManageFeature()
          },
        ),
      )
    },
  )
}
