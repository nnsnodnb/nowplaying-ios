//
//  MigrateV320Page.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
//

import CommonModule
import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct MigrateV320Feature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var isLoading = false
    public var failedCount = 0
    public var twitterAccounts: [TwitterAccount] = []
    @Shared(.appStorage(.migratedV320))
    public var migratedV320 = false
    @Shared(.appStorage(.freeTwitterLoginCount))
    public var freeTwitterLoginCount = 0
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case migrate
    case forceContinueTheApp
    case delegate(Delegate)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case completed
    }

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedTwitterAccounts([TwitterAccount])
      case migrated
      case failedMigrate
      case deletedTwitterAccounts
    }

    // MARK: - Action
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case retry
      case forceContinue
    }
  }

  // MARK: - Dependency
  @Dependency(\.functions)
  private var functions
  @Dependency(\.mainQueue)
  private var mainQueue
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if state.migratedV320 {
          return .send(.internalAction(.migrated))
        }
        return .run(
          operation: { send in
            let twitterAccounts = try await secureKeyValueStore.getTwitterAccounts()
            guard !twitterAccounts.isEmpty else {
              await send(.internalAction(.migrated))
              return
            }
            await send(.internalAction(.fetchedTwitterAccounts(twitterAccounts)))
          },
        )
      case .migrate:
        if state.migratedV320 {
          // 発生し得ないと思うが念のため広告なしログインのカウントをリセットしておく
          state.$freeTwitterLoginCount.withLock { $0 = 0 }
          return .send(.internalAction(.migrated))
        }
        state.isLoading = true
        return .run(
          operation: { send in
            let twitterAccounts = try await secureKeyValueStore.getTwitterAccounts()
            guard !twitterAccounts.isEmpty else {
              await send(.internalAction(.migrated))
              return
            }
            var migrations: [Migration.V320] = []
            for twitterAccount in twitterAccounts {
              guard let oauthToken = try await secureKeyValueStore.getTwitterOAuthToken(twitterAccount) else {
                continue
              }
              migrations.append(.init(twitterAccount: twitterAccount, refreshToken: oauthToken.refreshToken))
            }
            if !migrations.isEmpty {
              try await functions.migrateTwitterUserProfiles(migrations)
              // マイグレーションに成功したのでTwitterOAuthTokenは削除しておく
              for migration in migrations {
                try await secureKeyValueStore.removeTwitterOAuthToken(migration.twitterAccount)
              }
            }
            await send(.internalAction(.migrated))
          },
          catch: { _, send in
            await send(.internalAction(.failedMigrate))
          },
        )
      case .forceContinueTheApp:
        return .run(
          operation: { [twitterAccounts = state.twitterAccounts] send in
            // keychainからTwitterAccountを削除する
            for twitterAccount in twitterAccounts {
              try await secureKeyValueStore.removeTwitterAccount(twitterAccount)
            }
            await send(.internalAction(.deletedTwitterAccounts))
          },
        )
      case .delegate:
        return .none
      case let .internalAction(.fetchedTwitterAccounts(twitterAccounts)):
        state.twitterAccounts = twitterAccounts
        return .none
      case .internalAction(.migrated):
        state.$migratedV320.withLock { $0 = true }
        state.$freeTwitterLoginCount.withLock { $0 = 0 }
        state.isLoading = false
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(200))
            await send(.delegate(.completed))
          },
        )
      case .internalAction(.failedMigrate):
        state.isLoading = false
        state.failedCount += 1
        let title: (() -> TextState)
        let message: (() -> TextState)?
        if state.failedCount >= 2 {
          title = { [failedCount = state.failedCount] in
            TextState(.dataMigrationHasFailedTimes(failedCount))
          }
          message = {
            TextState(.youWillNeedToLogInAgainWithYourXAccountButYouCanContinueUsingTheAppAsIs)
          }
        } else {
          title = {
            TextState(.failedMigrateData)
          }
          message = nil
        }
        state.alert = AlertState(
          title: title,
          actions: {
            ButtonState(
              action: .retry,
              label: {
                TextState(.retry)
              },
            )
            if state.failedCount >= 2 {
              ButtonState(
                action: .forceContinue,
                label: {
                  TextState(.continue)
                },
              )
            }
          },
          message: message,
        )
        return .none
      case .internalAction(.deletedTwitterAccounts):
        // マイグレーション済みフラグ
        state.$migratedV320.withLock { $0 = true }
        // 広告なしログイン可能数を確保
        state.$freeTwitterLoginCount.withLock { $0 = state.twitterAccounts.count }
        return .send(.delegate(.completed))
      case .internalAction:
        return .none
      case .alert(.presented(.retry)):
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(400))
            await send(.migrate)
          },
        )
      case .alert(.presented(.forceContinue)):
        return .send(.forceContinueTheApp)
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct MigrateV320Page: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<MigrateV320Feature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        VStack(alignment: .center, spacing: 8) {
          list
          migrateButton
          openAppButton
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle(.dataMigrate)
        .toolbarTitleDisplayMode(.inlineLarge)
        .task {
          store.send(.onAppear)
        }
      },
    )
    .progress(store.isLoading, status: String(localized: .migratingData))
    .alert($store.scope(state: \.$alert, action: \.alert))
    .analyticsScreen(screenName: .migrateV320)
  }

  private var list: some View {
    List {
      Text(.migrationMessage)
      ForEach(store.twitterAccounts, id: \.profile.id) { twitterAccount in
        row(twitterAccount: twitterAccount)
      }
    }
    .listStyle(.insetGrouped)
  }

  private func row(twitterAccount: TwitterAccount) -> some View {
    TwitterProfileRow(
      twitterAccount: twitterAccount,
      showDefaultStar: false,
      selected: false,
    )
  }

  private var migrateButton: some View {
    createButton(
      action: {
        store.send(.migrate)
      },
      title: .dataMigrate,
    )
    .modifier {
      if #available(iOS 26.0, *) {
        $0.buttonStyle(.glassProminent)
      } else {
        $0.buttonStyle(.borderedProminent)
      }
    }
  }

  private var openAppButton: some View {
    createButton(
      action: {
        store.send(.forceContinueTheApp)
      },
      title: .continueToTheApp,
    )
    .fontWeight(.bold)
    .modifier {
      if #available(iOS 26.0, *) {
        $0.buttonStyle(.glass)
      } else {
        $0.buttonStyle(.plain)
      }
    }
  }

  private func createButton(
    action: @escaping () -> Void,
    title: LocalizedStringResource,
  ) -> some View {
    Button(
      action: action,
      label: {
        Text(title)
          .padding(8)
          .frame(maxWidth: .infinity, minHeight: 36)
      },
    )
    .padding(.horizontal, 12)
    .disabled(store.isLoading)
  }
}

#Preview {
  MigrateV320Page(
    store: .init(
      initialState: MigrateV320Feature.State(),
      reducer: {
        MigrateV320Feature()
          .dependency(\.defaultAppStorage, .inMemory)
      },
    ),
  )
}
