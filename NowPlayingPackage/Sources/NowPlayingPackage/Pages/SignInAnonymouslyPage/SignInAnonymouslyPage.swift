//
//  SignInAnonymouslyPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/14.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SignInAnonymouslyFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
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
      case signInAnonymously
      case signInFailure
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case retry
    }
  }

  // MARK: - Dependency
  @Dependency(\.auth)
  private var auth
  @Dependency(\.mainQueue)
  private var mainQueue

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .signInIfNeeded:
        // すでにサインイン済み && 匿名ユーザー
        if auth.isSignedIn() && auth.isAnonymous() {
          return .send(.delegate(.completed))
        }
        // UIKit時代の名残でTwitterログインセッションが残っているかもしれないのでログアウトする
        try? auth.signOut()
        return .send(.internalAction(.signInAnonymously))
      case .delegate:
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
    Color(UIColor.systemBackground)
      .ignoresSafeArea(.all)
      .task {
        store.send(.signInIfNeeded)
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
