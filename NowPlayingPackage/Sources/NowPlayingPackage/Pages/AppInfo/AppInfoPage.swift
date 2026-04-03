//
//  AppInfoPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
import SwiftUI
import Version

@Reducer
public struct AppInfoFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public var viewState: ViewState = .initial
    public var updateAvailableVersion: Version?
    @Shared(.appStorage(.skippedUpdateVersion))
    public var skippedUpdateVersion: Version?
    @Presents public var alert: AlertState<Action.Alert>?

    // MARK: - ViewState
    public enum ViewState: Sendable {
      case initial
      case updateRequire
      case updateAvailable
    }
  }

  // MARK: - Action
  public enum Action {
    case fetchAppInfo
    case openAppStore
    case updateLater
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
      case updateRequired
      case updateAvailable(Version)
      case fetchFailed
      case completed
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case retry
    }
  }

  // MARK: - Dependency
  @Dependency(\.apiClient)
  private var apiClient
  @Dependency(\.bundle)
  private var bundle
  @Dependency(\.continuousClock)
  private var continuousClock
  @Dependency(\.openURL)
  private var openURL

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchAppInfo:
        return .run(
          operation: { send in
            let appInfo = try await apiClient.getAppInfo()
            let shortVersionString = bundle.shortVersionString()
            let currentVersion = Version(shortVersionString.split(separator: "-", maxSplits: 1)[safe: 0] ?? "")!
            let updateAvailableVersion = Version(appInfo.appVersion.latest)!
            if currentVersion < Version(appInfo.appVersion.require)! {
              await send(.internalAction(.updateRequired))
            } else if currentVersion < updateAvailableVersion {
              await send(.internalAction(.updateAvailable(updateAvailableVersion)))
            } else {
              await send(.internalAction(.completed))
            }
          },
          catch: { _, send in
            await send(.internalAction(.fetchFailed))
          },
        )
      case .openAppStore:
        return .run(
          operation: { _ in
            await openURL(URL(string: "https://itunes.apple.com/jp/app/id1289764391?mt=8")!)
          },
        )
      case .updateLater:
        state.$skippedUpdateVersion.withLock { $0 = state.updateAvailableVersion }
        return .send(.delegate(.completed))
      case .delegate:
        return .none
      case .internalAction(.updateRequired):
        state.viewState = .updateRequire
        return .none
      case let .internalAction(.updateAvailable(updateAvailableVersion)):
        state.updateAvailableVersion = updateAvailableVersion
        if let skippedUpdateVersion = state.skippedUpdateVersion,
           updateAvailableVersion <= skippedUpdateVersion {
          // すでにスキップバージョンなので終了
          return .send(.delegate(.completed))
        }
        state.viewState = .updateAvailable
        return .none
      case .internalAction(.fetchFailed):
        state.alert = AlertState(
          title: {
            TextState(.failedToRetrieveAppInformation)
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
      case .internalAction(.completed):
        return .send(.delegate(.completed))
      case .internalAction:
        return .none
      case .alert(.presented(.retry)):
        return .run(
          operation: { send in
            try await continuousClock.sleep(for: .milliseconds(500))
            await send(.fetchAppInfo)
          },
        )
      case .alert:
        return .none
      }
    }
  }
}

public struct AppInfoPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<AppInfoFeature>

  // MARK: - Body
  public var body: some View {
    switch store.viewState {
    case .initial:
      Color(UIColor.systemBackground.withAlphaComponent(0.000001))
        .ignoresSafeArea(.all)
        .task {
          store.send(.fetchAppInfo)
        }
        .alert($store.scope(state: \.$alert, action: \.alert))
    case .updateRequire:
      updateRequire
    case .updateAvailable:
      updateAvailable
    }
  }

  private var updateRequire: some View {
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 12) {
        Image(.icAppicon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 64, height: 64)
          .clipShape(RoundedRectangle(cornerRadius: 12))
        Text(.updateRequired)
          .font(.system(size: 20, weight: .bold))
        Button(
          action: {
            store.send(.openAppStore)
          },
          label: {
            Text(.openAppStore)
              .padding(8)
          },
        )
        .buttonStyle(.borderedProminent)
      }
    }
  }

  private var updateAvailable: some View {
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 12) {
        Image(.icAppicon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 64, height: 64)
          .clipShape(RoundedRectangle(cornerRadius: 12))
        Text(.updateRequired)
          .font(.system(size: 20, weight: .bold))
      }
      VStack(alignment: .center, spacing: 12) {
        Button(
          action: {
            store.send(.openAppStore)
          },
          label: {
            Text(.openAppStore)
              .padding(8)
          },
        )
        .buttonStyle(.borderedProminent)
        Button(
          action: {
            store.send(.updateLater)
          },
          label: {
            Text(.later)
              .padding(8)
          },
        )
        .buttonStyle(.bordered)
      }
    }
  }
}

#Preview {
  AppInfoPage(
    store: .init(
      initialState: AppInfoFeature.State(),
      reducer: {
        AppInfoFeature()
      },
    ),
  )
}
