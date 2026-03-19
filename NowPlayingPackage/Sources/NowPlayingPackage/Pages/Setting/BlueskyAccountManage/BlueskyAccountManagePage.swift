//
//  BlueskyAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import BetterSafariView
import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskyAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public var blueskyAccounts: [BlueskyAccount] = []
    public var safari: Safari?

    // MARK: - Safari
    public enum Safari: Equatable, Identifiable {
      case howToAddBlueskyAccount

      // MARK: - Identifiable
      public var id: String {
        url.absoluteString
      }

      // MARK: - Properties
      public var url: URL {
        switch self {
        case .howToAddBlueskyAccount:
          URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Add-Bluesky-Account#blueskyアカウント追加方法")!
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case fetchBlueskyAccounts
    case changedSafari(State.Safari?)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedBlueskyAccounts([BlueskyAccount])
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchBlueskyAccounts:
        return .none
      case let .changedSafari(safari):
        state.safari = safari
        return .none
      case let .internalAction(.fetchedBlueskyAccounts(blueskyAccounts)):
        state.blueskyAccounts = blueskyAccounts
        return .none
      case .internalAction:
        return .none
      }
    }
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
          // TODO: 追加
        },
      )
      .onAppear {
        store.send(.fetchBlueskyAccounts)
      }
      .safariView(item: $store.safari.sending(\.changedSafari)) { safari in
        SafariView(url: safari.url)
          .dismissButtonStyle(.close)
      }
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
            // TODO: store.send(.deleteBlueskyAccount(indexSet))
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
        // TODO: store.send(.changeDefaultAccount(blueskyAccount))
      },
      label: {
        Text(blueskyAccount.handler)
          .foregroundStyle(Color.primary)
      },
    )
  }
}

private extension View {
  func toolbar(helpAction: @escaping @MainActor () -> Void, addAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      // ToolbarItem(placement: .primaryAction) {
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
