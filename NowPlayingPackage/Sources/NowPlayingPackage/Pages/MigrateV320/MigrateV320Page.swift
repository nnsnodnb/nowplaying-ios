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
    @Shared(.appStorage(.migratedV320))
    public var migratedV320 = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case migrate
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
      case migrated
      case failedMigrate
    }

    // MARK: - Action
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case retry
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
      case .migrate:
        if state.migratedV320 {
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
      case .delegate:
        return .none
      case .internalAction(.migrated):
        state.$migratedV320.withLock { $0 = true }
        state.isLoading = false
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(200))
            await send(.delegate(.completed))
          },
        )
      case .internalAction(.failedMigrate):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(.failedMigrateData)
          },
          actions: {
            ButtonState(
              action: .retry,
              label: {
                TextState(.retry)
              },
            )
          },
        )
        return .none
      case .internalAction:
        return .none
      case .alert(.presented(.retry)):
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(400))
            await send(.migrate)
          },
        )
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
    Color(UIColor.systemBackground)
      .ignoresSafeArea(.all)
      .task {
        store.send(.migrate)
      }
      .progress(store.isLoading, status: String(localized: .migratingData))
      .alert($store.scope(state: \.$alert, action: \.alert))
      .analyticsScreen(screenName: .migrateV320)
  }
}

#Preview {
  MigrateV320Page(
    store: .init(
      initialState: MigrateV320Feature.State(),
      reducer: {
        MigrateV320Feature()
      },
    ),
  )
}
