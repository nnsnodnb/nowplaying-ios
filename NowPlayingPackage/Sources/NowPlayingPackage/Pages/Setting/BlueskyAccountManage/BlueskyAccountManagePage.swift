//
//  BlueskyAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import ATProtoKit
import BetterSafariView
import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskyAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var blueskyAccounts: [BlueskyAccount] = []
    public var safari: Safari?
    @Presents public var blueskyLogin: BlueskyLoginFeature.State?
    @Presents public var alert: AlertState<Action.Alert>?

    // MARK: - Safari
    public enum Safari: Equatable, Identifiable, Sendable {
      case howToAddBlueskyAccount

      // MARK: - Identifiable
      public var id: String {
        url.absoluteString
      }

      // MARK: - Properties
      public var url: URL {
        switch self {
        case .howToAddBlueskyAccount:
          URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Add-Bluesky-Account#nowplayingアプリでのログイン")!
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case fetchBlueskyAccounts
    case changedSafari(State.Safari?)
    case addAccount
    case changeDefaultAccount(BlueskyAccount)
    case deleteBlueskyAccount(IndexSet)
    case blueskyLogin(PresentationAction<BlueskyLoginFeature.Action>)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedBlueskyAccounts([BlueskyAccount])
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
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchBlueskyAccounts:
        return .run(
          operation: { send in
            let blueskyAccounts = try await secureKeyValueStore.getBlueskyAccounts()
            await send(.internalAction(.fetchedBlueskyAccounts(blueskyAccounts)))
          },
        )
      case let .changedSafari(safari):
        state.safari = safari
        return .none
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
            TextState("ログインしました！")
          },
          message: {
            TextState(message)
          },
        )
        return .send(.fetchBlueskyAccounts)
      case .blueskyLogin:
        return .none
      case let .internalAction(.fetchedBlueskyAccounts(blueskyAccounts)):
        state.blueskyAccounts = blueskyAccounts
        return .run(
          operation: { _ in
            await analytics.setUserProperty(.blueskyAccountsCount(blueskyAccounts.count + 1))
          },
        )
      case .internalAction:
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$blueskyLogin, action: \.blueskyLogin) {
      BlueskyLoginFeature()
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct BlueskyAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskyAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("Blueskyアカウント管理")
      .toolbar(
        helpAction: {
          store.send(.changedSafari(.howToAddBlueskyAccount))
        },
        addAction: {
          store.send(.addAccount)
        },
      )
      .task {
        store.send(.fetchBlueskyAccounts)
      }
      .safariView(item: $store.safari.sending(\.changedSafari)) { safari in
        SafariView(url: safari.url)
          .dismissButtonStyle(.close)
      }
      .sheet(
        item: $store.scope(state: \.$blueskyLogin, action: \.blueskyLogin),
        content: { store in
          BlueskyLoginPage(store: store)
        },
      )
      .alert($store.scope(state: \.$alert, action: \.alert))
      .analyticsScreen(screenName: .blueskyAccountManage)
  }

  @ViewBuilder private var list: some View {
    if store.blueskyAccounts.isEmpty {
      empty
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

  private var empty: some View {
    ContentUnavailableView(
      label: {
        VStack(alignment: .center, spacing: 24) {
          Image(systemSymbol: .at)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
          Text("アカウントがありません")
        }
        .foregroundStyle(.secondary)
      }
    )
    .background {
      Color(UIColor.systemGroupedBackground)
    }
    .ignoresSafeArea(.all)
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
  func toolbar(helpAction: @escaping @MainActor () -> Void, addAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button(
          action: helpAction,
          label: {
            if #available(iOS 26.0, *) {
              Image(systemSymbol: .questionmark)
            } else {
              Image(systemSymbol: .questionmarkCircle)
            }
          },
        )
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
  BlueskyAccountManagePage(
    store: .init(
      initialState: BlueskyAccountManageFeature.State(),
      reducer: {
        BlueskyAccountManageFeature()
      },
    ),
  )
}
