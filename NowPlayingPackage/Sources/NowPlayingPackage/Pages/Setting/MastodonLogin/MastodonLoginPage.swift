//
//  MastodonLoginPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import ComposableArchitecture
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
    }

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
    }
  }

  // MARK: - Dependency
  @Dependency(\.dismiss)
  private var dismiss
  @Dependency(\.mastodonAPI)
  private var mastodonAPI

  // MARK: - Body
  public var body: some ReducerOf<Self> {
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
              await send(.internalAction(.getMastodonInstanceFailure(.theInstanceDomainMayBeIncorrect)))
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
        // TODO: アプリ追加など
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
