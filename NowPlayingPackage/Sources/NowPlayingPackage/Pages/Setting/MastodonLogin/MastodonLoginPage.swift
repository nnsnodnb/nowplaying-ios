//
//  MastodonLoginPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import BetterSafariView
import ComposableArchitecture
import MastodonKit
import NukeUI
import SwiftUI

@Reducer
public struct MastodonLoginFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var isCheckButtonDisabled = true
    public var domain = ""
    public var mastodonInstance: MastodonInstance?
    public var oauthURL: URL?
    public var clientApplication: MastodonClientApplication?
    public var isFocused = true
    public var isLoading = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action: BindableAction {
    case close
    case check
    case changedDomain(String)
    case login
    case changedOAuthURL(URL?)
    case authenticateSuccess(URL)
    case authenticateFailure(any Error)
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)
    case internalAction(InternalAction)
    case delegate(Delegate)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Sendable {
      case close
    }

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case getMastodonInstanceSuccess(MastodonInstance)
      case getMastodonInstanceFailure(LocalizedStringResource)
      case startOAuth(URL, MastodonClientApplication)
      case savedMastodonAccount(MastodonAccount)
    }

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case loggedIn(MastodonAccount)
    }
  }

  // MARK: - Dependency
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.mastodonAPI)
  private var mastodonAPI
  @Dependency(\.mastodonOAuth)
  private var mastodonOAuth

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
      case .check:
        guard !state.isCheckButtonDisabled else { return .none }
        // すでに検索済みであれば再検索しない
        if state.mastodonInstance?.domain == state.domain { return .none }
        state.isFocused = false
        state.isLoading = true
        return .run(
          operation: { [state] send in
            let url = URL(string: "https://\(state.domain)")!
            let mastodonInstance = try await mastodonAPI.getInstanceDetail(url)
            await send(.internalAction(.getMastodonInstanceSuccess(mastodonInstance)))
          },
          catch: { error, send in
            guard let error = error as? MastodonAPIClient.Error else {
              await send(.internalAction(.getMastodonInstanceFailure(.anUnknownErrorHasOccurred)))
              return
            }
            switch error {
            case .invalidURL:
              await send(.internalAction(.getMastodonInstanceFailure(.isTheInstanceDomainIncorrect)))
            case .internalError:
              await send(.internalAction(.getMastodonInstanceFailure(.anUnknownErrorHasOccurred)))
            }
          },
        )
      case let .changedDomain(domain):
        state.domain = domain
        if let url = URL(string: "https://\(domain)"),
            url.scheme == "https",
           url.host() != nil {
          state.isCheckButtonDisabled = false
        } else {
          state.isCheckButtonDisabled = true
        }
        return .none
      case .login:
        state.isLoading = true
        state.isFocused = false // フォーカスをユーザーが再度当てている可能性があるので強制的に閉じておく
        return .run(
          operation: { [state] send in
            let clientApplication = try await mastodonAPI.registerApplication(state.domain)
            let oauthURL = try mastodonOAuth.getAuthenticateURL(clientApplication)
            await send(.internalAction(.startOAuth(oauthURL, clientApplication)))
          },
          catch: { error, send in
            // TODO: エラーハンドリング
          },
        )
      case let .changedOAuthURL(url):
        state.oauthURL = url
        return .none
      case let .authenticateSuccess(url):
        guard let clientApplication = state.clientApplication else { return .none }
        return .run(
          operation: { send in
            let authorizationCode = try mastodonOAuth.validateCallbackURL(url)
            let loginSettings = try await mastodonOAuth.requestAccessToken(clientApplication, authorizationCode)
            let mastodonAccount = try await mastodonOAuth.verifyAccessToken(clientApplication, loginSettings)
            // TODO: LoginSettingsとMastodonProfile保存
            await send(.internalAction(.savedMastodonAccount(mastodonAccount)))
          },
          catch: { error, send in
            guard let error = error as? MastodonOAuthClient.Error else { return }
            switch error {
            case .invalidCallbackURL:
              // TODO: エラーハンドリング
              return
            case .internalError:
              // TODO: エラーハンドリング
              return
            }
          },
        )
      case let .authenticateFailure(error):
        guard let errorCode = WebAuthenticationSessionError.Code(rawValue: (error as NSError).code),
              errorCode != .canceledLogin else {
          state.isLoading = false
          return .none
        }
        // TODO: エラーハンドリング
        state.isLoading = false
        return .none
      case .binding:
        return .none
      case .alert:
        return .none
      case let .internalAction(.getMastodonInstanceSuccess(mastodonInstance)):
        state.isLoading = false
        state.mastodonInstance = mastodonInstance
        return .none
      case let .internalAction(.getMastodonInstanceFailure(title)):
        state.isFocused = true
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
              },
            )
          },
        )
        return .none
      case let .internalAction(.startOAuth(oauthURL, clientApplication)):
        state.oauthURL = oauthURL
        state.clientApplication = clientApplication
        return .none
      case let .internalAction(.savedMastodonAccount(mastodonAccount)):
        state.isLoading = false
        return .run(
          operation: { send in
            await send(.delegate(.loggedIn(mastodonAccount)))
            await send(.close)
          },
        )
      case .internalAction:
        return .none
      case .delegate:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct MastodonLoginPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<MastodonLoginFeature>

  @FocusState private var isFocused: Bool

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        form
          .navigationTitle(.loginInformation)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            closeAction: {
              store.send(.close)
            },
            checkButtonDisabled: store.isCheckButtonDisabled,
            checkAction: {
              store.send(.check)
            },
          )
          .interactiveDismissDisabled(store.mastodonInstance != nil)
          .webAuthenticationSession(
            item: $store.oauthURL.sending(\.changedOAuthURL),
            content: { content in
              webAuthenticationSession(url: content)
            },
          )
          .progress(store.isLoading)
          .alert($store.scope(state: \.$alert, action: \.alert))
      },
    )
    .analyticsScreen(screenName: .mastodonLogin)
  }

  private var form: some View {
    Form {
      firstSection
      secondSection
    }
  }

  private var firstSection: some View {
    Section {
      urlTextField
    }
    .bind($store.isFocused, to: $isFocused)
  }

  @ViewBuilder private var secondSection: some View {
    if let mastodonInstance = store.mastodonInstance {
      Section {
        VStack(alignment: .center, spacing: 12) {
          LazyImage(url: mastodonInstance.thumbnail.url) { state in
            if let image = state.image {
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if state.isLoading {
              ProgressView()
                .progressViewStyle(.circular)
            }
          }
          Text(.doYouWantToLogInTo(mastodonInstance.domain))
            .font(.system(size: 16))
          Button(
            action: {
              store.send(.login)
            },
            label: {
              Text(.logIn)
            },
          )
          .modifier {
            if #available(iOS 26.0, *) {
              $0.buttonStyle(.glassProminent)
            } else {
              $0.buttonStyle(.borderedProminent)
            }
          }
        }
      }
      .animation(.easeInOut.speed(0.3), value: store.mastodonInstance)
    }
  }

  private var urlTextField: some View {
    HStack(alignment: .center, spacing: 8) {
      Text("https://")
      Divider()
      TextField(
        text: $store.domain.sending(\.changedDomain),
        label: {
          Text("mastodon.social")
        },
      )
      .keyboardType(.URL)
      .focused($isFocused)
    }
  }

  private func webAuthenticationSession(url: URL) -> WebAuthenticationSession {
    WebAuthenticationSession(
      url: url,
      callbackURLScheme: "nowplaying-ss5dnc-el0eskszufn3qactsets",
      onCompletion: { result in
        switch result {
        case let .success(url):
          store.send(.authenticateSuccess(url))
        case let .failure(error):
          store.send(.authenticateFailure(error))
        }
      },
    )
    .prefersEphemeralWebBrowserSession(true)
  }
}

private extension View {
  func toolbar(
    closeAction: @escaping @MainActor () -> Void,
    checkButtonDisabled: Bool,
    checkAction: @escaping @MainActor () -> Void,
  ) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CancellationButton(
          action: closeAction,
        )
      }
      ToolbarItem(placement: .confirmationAction) {
        ConfirmationButton(
          action: checkAction,
          title: String(localized: .check),
        )
        .disabled(checkButtonDisabled)
      }
    }
  }
}

#Preview {
  MastodonLoginPage(
    store: .init(
      initialState: MastodonLoginFeature.State(),
      reducer: {
        MastodonLoginFeature()
      },
    ),
  )
}
