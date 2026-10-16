//
//  BlueskyLoginPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import CommonModule
import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct BlueskyLoginFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var handle = ""
    public var focusedField: Field? = .handle
    public var isDisabledLoginButton = false
    public var isLoading = false
    @Presents public var alert: AlertState<Action.Alert>?

    // MARK: - Field
    public enum Field: Sendable {
      case handle
    }
  }

  // MARK: - Action
  public enum Action: BindableAction {
    case close
    case login
    case changedHandle(String)
    case binding(BindingAction<State>)
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
      case loggedIn(BlueskyAccount)
      case loginFailure(String)
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.blueskyAPI)
  private var blueskyAPI
  @Dependency(\.blueskyOAuth)
  private var blueskyOAuth
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .close:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case .login:
        guard !state.isDisabledLoginButton else { return .none }
        state.focusedField = nil
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let identity = try await blueskyOAuth.resolveIdentity(handle: state.handle)
            let privateKey = try await secureKeyValueStore.getBlueskyAccountPrivateKey(identity.did)
            let authenticator = try await blueskyOAuth.makeAuthenticator(
              handle: state.handle,
              identity: identity,
              key: privateKey,
            )
            try await authenticator.authenticate()
            let blueskyAccount = try await blueskyAPI.getUserProfile(state.handle, identity)
            try await secureKeyValueStore.addBlueskyAccount(blueskyAccount)
            try await secureKeyValueStore.setBlueskyAccountIdentity(identity)
            await send(.internalAction(.loggedIn(blueskyAccount)))
          },
          catch: { error, send in
            // TODO: エラー修正
            guard let error = error as? BlueskyAPIClient.Error else {
              await send(.internalAction(.loginFailure(String(localized: .anUnknownErrorHasOccurred))))
              return
            }
            switch error {
            case .invalidHandleOrPassword:
              await send(.internalAction(.loginFailure(String(localized: .isYourHandleOrPasswordIncorrect))))
            case .enabledTwoFactorAuthentication:
              await send(
                .internalAction(.loginFailure(String(localized: .twoFactorAuthenticationIsEnabledPleaseEnterYourAppPassword)))
              )
            case .invalidHandle:
              await send(.internalAction(.loginFailure(String(localized: .isYourHandleIncorrect))))
            case .requiredLogin:
              // MEMO: 普通は絶対にでない
              await send(.internalAction(.loginFailure(String(localized: .pleaseLogInFirst))))
            case .unknown:
              await send(.internalAction(.loginFailure(String(localized: .anUnknownErrorHasOccurred))))
            }
          },
        )
      case let .changedHandle(handle):
        state.handle = handle
        state.isDisabledLoginButton = handle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .none
      case .binding:
        return .none
      case .delegate:
        return .none
      case let .internalAction(.loggedIn(blueskyAccount)):
        state.isLoading = false
        return .run(
          operation: { [handle = state.handle] send in
            await analytics.logEvent(.blueskyLogin(true, handle))
            await send(.delegate(.loggedIn(blueskyAccount)))
            await send(.close)
          },
        )
      case let .internalAction(.loginFailure(message)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(.anErrorHasOccurred)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          },
          message: {
            TextState(message)
          }
        )
        return .run(
          operation: { [handle = state.handle] _ in
            await analytics.logEvent(.blueskyLogin(false, handle))
          },
        )
      case .internalAction:
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.alert, action: \.alert)
  }
}

public struct BlueskyLoginPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskyLoginFeature>

  @FocusState private var focusedField: BlueskyLoginFeature.State.Field?

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle(.loginInformation)
          .navigationBarTitleDisplayMode(.inline)
          .navigationScrollEdgeEffectSoft()
          .toolbar(
            closeAction: {
              store.send(.close)
            },
            loginButtonDisabled: store.isDisabledLoginButton,
            loginAction: {
              focusedField = nil
              store.send(.login)
            },
          )
          .progress(store.isLoading)
          .alert($store.scope(\.alert, action: \.alert))
      },
    )
    .analyticsScreen(screenName: .blueskyLogin)
  }

  private var form: some View {
    Form {
      section
    }
  }

  private var section: some View {
    Section {
      handleTextField
    }
    .bind($store.focusedField, to: $focusedField)
  }

  private var handleTextField: some View {
    TextField(
      text: $store.handle.sending(\.changedHandle),
      label: {
        Text(.handle)
      },
    )
    .keyboardType(.twitter)
    .focused($focusedField, equals: .handle)
  }
}

private extension View {
  func toolbar(
    closeAction: @escaping @MainActor () -> Void,
    loginButtonDisabled: Bool,
    loginAction: @escaping @MainActor () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CancellationButton(
          action: closeAction,
        )
      }
      ToolbarItem(placement: .confirmationAction) {
        ConfirmationButton(
          action: loginAction,
          title: String(localized: .logIn),
        )
        .disabled(loginButtonDisabled)
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
