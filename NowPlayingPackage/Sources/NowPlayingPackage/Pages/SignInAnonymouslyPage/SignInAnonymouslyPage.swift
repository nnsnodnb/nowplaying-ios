//
//  SignInAnonymouslyPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/14.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct SignInAnonymouslyFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    @Shared(.appStorage(.migratedV320))
    public var migratedV320 = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case signInIfNeeded
    case delegate(Delegate)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case completed
    }

    // MARK: - IntenralAction
    @CasePathable
    public enum InternalAction {
      case deletePreviousAnonymouslyUser
      case deleteFailure
      case signInAnonymously
      case signInFailure
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case retryDeleteUser
      case retrySignIn
    }
  }

  // MARK: - Dependency
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.auth)
  private var auth
  @Dependency(\.functions)
  private var functions
  @Dependency(\.mainQueue)
  private var mainQueue

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .signInIfNeeded:
        // すでにサインイン済み && 匿名ユーザー
        if auth.isSignedIn() && auth.isAnonymous() {
          if state.migratedV320 {
            // マイグレーションも完了しているので終了
            return .send(.delegate(.completed))
          } else {
            // マイグレーションをしていない→再インストールのユーザーなので前の匿名ユーザーを削除する
            return .send(.internalAction(.deletePreviousAnonymouslyUser))
          }
        }
        // UIKit時代の名残でTwitterログインセッションが残っているかもしれないのでログアウトする
        try? auth.signOut()
        return .send(.internalAction(.signInAnonymously))
      case .delegate:
        return .none
      case .internalAction(.deletePreviousAnonymouslyUser):
        return .run(
          operation: { send in
            try await functions.deleteAnonymouslyUser()
            try? auth.signOut()
            await analytics.logEvent(.reinstalled)
            // 削除完了に匿名認証をする
            await send(.internalAction(.signInAnonymously))
          },
          catch: { _, send in
            await send(.internalAction(.deleteFailure))
          },
        )
      case .internalAction(.deleteFailure):
        state.alert = AlertState(
          title: {
            TextState(.failedLoad)
          },
          actions: {
            ButtonState(
              action: .retryDeleteUser,
              label: {
                TextState(.retry)
              },
            )
          },
        )
        return .none
      case .internalAction(.signInAnonymously):
        return .run(
          operation: { send in
            try await auth.signInAnonymously()
            await send(.delegate(.completed))
          },
          catch: { _, send in
            await send(.internalAction(.signInFailure))
          },
        )
      case .internalAction(.signInFailure):
        state.alert = AlertState(
          title: {
            TextState(.failedLoad)
          },
          actions: {
            ButtonState(
              action: .retrySignIn,
              label: {
                TextState(.retry)
              },
            )
          },
        )
        return .none
      case .internalAction:
        return .none
      case .alert(.presented(.retryDeleteUser)):
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(400))
            await send(.internalAction(.deletePreviousAnonymouslyUser))
          },
        )
      case .alert(.presented(.retrySignIn)):
        return .run(
          operation: { send in
            try await mainQueue.sleep(for: .milliseconds(400))
            await send(.internalAction(.signInAnonymously))
          },
        )
      case .alert:
        return .none
      }
    }
    .ifLet(\.alert, action: \.alert)
  }
}

public struct SignInAnonymouslyPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SignInAnonymouslyFeature>

  // MARK: - Body
  public var body: some View {
    ProgressView()
      .progressViewStyle(.circular)
      .frame(maxWidth: .infinity)
      .controlSize(.extraLarge)
      .task {
        await store.send(.signInIfNeeded).finish()
      }
      .alert($store.scope(\.alert, action: \.alert))
      .analyticsScreen(screenName: .signInAnonymously)
  }
}

#Preview {
  SignInAnonymouslyPage(
    store: .init(
      initialState: SignInAnonymouslyFeature.State(),
      reducer: {
        SignInAnonymouslyFeature()
      },
    ),
  )
}
