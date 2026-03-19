//
//  BlueskyLoginPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskyLoginFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var handle = ""
    public var password = ""
    public var isDisabledLoginButton = true
    public var isLoading = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case changedHandle(String)
    case changedPassword(String)
    case login
    case delegate(Delegate)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case loggedIn(BlueskyAccount)
    }

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case validate
      case loggedIn(BlueskyAccount)
      case loginFailure(String)
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
    }
  }

  @Dependency(\.blueskyAPI)
  private var blueskyAPI
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .changedHandle(handle):
        state.handle = handle
        return .send(.internalAction(.validate))
      case let .changedPassword(password):
        state.password = password
        return .send(.internalAction(.validate))
      case .login:
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let blueskyAccount = try await blueskyAPI.login(state.handle, state.password)
            try await secureKeyValueStore.addBlueskyAccount(blueskyAccount)
            await send(.internalAction(.loggedIn(blueskyAccount)))
          },
          catch: { error, send in
            guard let error = error as? BlueskyAPIClient.Error else {
              await send(.internalAction(.loginFailure("不明なエラーが発生しました")))
              return
            }
            switch error {
            case .invalidHandleOrPassword:
              await send(.internalAction(.loginFailure("ハンドルもしくはパスワードが間違っていませんか？")))
            case .enabledTwoFactorAuthentication:
              await send(.internalAction(.loginFailure("2要素認証が有効になっています。アプリパスワードを入力してください")))
            case .invalidHandle:
              await send(.internalAction(.loginFailure("ハンドルが間違っていませんか？")))
            case .unknown:
              await send(.internalAction(.loginFailure("不明なエラーが発生しました")))
            }
          },
        )
      case .delegate:
        return .none
      case .internalAction(.validate):
        state.isDisabledLoginButton = state.handle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        state.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .none
      case let .internalAction(.loggedIn(blueskyAccount)):
        state.isLoading = false
        return .run(
          operation: { send in
            await send(.delegate(.loggedIn(blueskyAccount)))
            await dismiss()
          },
        )
      case let .internalAction(.loginFailure(message)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState("エラーが発生しました")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
          message: {
            TextState(message)
          }
        )
        return .none
      case .internalAction:
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct BlueskyLoginPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskyLoginFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle("ログイン情報")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            loginButtonDisabled: store.isDisabledLoginButton,
            loginAction: {
              store.send(.login)
            },
          )
          .progress(store.isLoading)
          .alert($store.scope(state: \.alert, action: \.alert))
      },
    )
  }

  private var form: some View {
    Form {
      Section {
        TextField(
          text: $store.handle.sending(\.changedHandle),
          label: {
            Text("ハンドル")
          },
        )
        SecureField(
          text: $store.password.sending(\.changedPassword),
          label: {
            Text("パスワード・アプリパスワード")
          },
        )
      }
    }
  }
}

private extension View {
  func toolbar(loginButtonDisabled: Bool, loginAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItem(placement: .confirmationAction) {
        if #available(iOS 26.0, *) {
          Button(
            role: .confirm,
            action: loginAction,
          )
          .disabled(loginButtonDisabled)
        } else {
          Button(
            action: loginAction,
            label: {
              Text("ログイン")
            },
          )
          .disabled(loginButtonDisabled)
        }
      }
    }
  }
}

#Preview {
  BlueskyLoginPage(
    store: .init(
      initialState: BlueskyLoginFeature.State(),
      reducer: {
        BlueskyLoginFeature()
      },
    ),
  )
}
