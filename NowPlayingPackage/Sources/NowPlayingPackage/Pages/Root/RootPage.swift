//
//  RootPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import ComposableArchitecture
import MemberwiseInit
import SwiftUI

@Reducer
@MemberwiseInit(.public)
public struct RootFeature: Sendable {
  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable, Sendable {
    @Init(default: nil)
    public var appInfo: AppInfoFeature.State?
    @Init(default: nil)
    public var consent: ConsentFeature.State?
    @Init(default: nil)
    public var play: PlayFeature.State?
    @Shared(.appStorage(.isLaunchAtFirst))
    public var isLaunchAtFirst = true
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case appInfo(AppInfoFeature.Action)
    case consent(ConsentFeature.Action)
    case play(PlayFeature.Action)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case resetedSecureAllData
      case showPlay(Bool)
    }
  }

  // MARK: - Dependency
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.appInfo = .init()
        guard state.isLaunchAtFirst else {
          return .none
        }
        // 初回起動時にKeychainのデータをすべて削除する
        return .run(
          operation: { send in
            try await secureKeyValueStore.resetAllData()
            await send(.internalAction(.resetedSecureAllData))
          },
        )
      case .appInfo(.delegate(.completed)):
        state.appInfo = nil
        state.consent = .init()
        return .none
      case .appInfo:
        return .none
      case .consent(.delegate(.completedConsent)):
        return .run(
          operation: { send in
            let nonConsumables = try await secureKeyValueStore.getNonConsumables()
            await send(.internalAction(.showPlay(nonConsumables.contains(.hideAds))))
          },
        )
      case .consent:
        return .none
      case .play:
        return .none
      case .internalAction(.resetedSecureAllData):
        state.$isLaunchAtFirst.withLock { $0 = false }
        return .none
      case let .internalAction(.showPlay(isPurchasedHideAds)):
        state.consent = nil
        state.play = .init(
          isPurchasedHideAds: isPurchasedHideAds,
        )
        return .none
      }
    }
    .ifLet(\.appInfo, action: \.appInfo) {
      AppInfoFeature()
    }
    .ifLet(\.consent, action: \.consent) {
      ConsentFeature()
    }
    .ifLet(\.play, action: \.play) {
      PlayFeature()
    }
  }
}

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  @Bindable public var store: StoreOf<RootFeature>

  // MARK: - Body
  public var body: some View {
    if let store = store.scope(state: \.appInfo, action: \.appInfo) {
      AppInfoPage(store: store)
    } else if let store = store.scope(state: \.consent, action: \.consent) {
      ConsentPage(store: store)
    } else if let store = store.scope(state: \.play, action: \.play) {
      PlayPage(store: store)
    } else {
      Text("")
        .onAppear {
          store.send(.onAppear)
        }
        .analyticsScreen(
          screenName: .root,
          extraParameters: [
            "is_launch_at_first": "\(store.isLaunchAtFirst)",
          ],
        )
    }
  }
}

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: .init(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      ),
    )
  }
}
