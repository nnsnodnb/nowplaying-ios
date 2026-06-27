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
  // MARK: - Destination
  @Reducer
  public enum Destination {
    case appInfo(AppInfoFeature)
    case consent(ConsentFeature)
    case signInAnonymously(SignInAnonymouslyFeature)
    case migrateV320(MigrateV320Feature)
    case play(PlayFeature)
  }

  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable, Sendable {
    @Init(default: nil)
    public var destination: Destination.State?
    @Shared(.appStorage(.isLaunchAtFirst))
    public var isLaunchAtFirst = true
    @Shared(.appStorage(.migratedV320))
    public var migratedV320 = false
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case destination(Destination.Action)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case resetedSecureAllData
      case showPlay(Bool)
    }
  }

  // MARK: - Dependency
  @Dependency(\.auth)
  private var auth
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.destination = .appInfo(.init())
        guard state.isLaunchAtFirst else {
          return .none
        }
        // 初回起動時にFirebaseAuthのセッションとKeychainのデータをすべて削除する
        return .run(
          operation: { send in
            try? auth.signOut()
            try await secureKeyValueStore.resetAllData()
            await send(.internalAction(.resetedSecureAllData))
          },
        )
      case .destination(.appInfo(.delegate(.completed))):
        state.destination = .consent(.init())
        return .none
      case .destination(.consent(.delegate(.completedConsent))):
        state.destination = .signInAnonymously(.init())
        return .none
      case .destination(.signInAnonymously(.delegate(.completed))):
        if state.migratedV320 {
          return .run(
            operation: { send in
              let nonConsumables = try await secureKeyValueStore.getNonConsumables()
              await send(.internalAction(.showPlay(nonConsumables.contains(.hideAds))))
            },
          )
        } else {
          state.destination = .migrateV320(.init())
          return .none
        }
      case .destination(.migrateV320(.delegate(.completed))):
        return .run(
          operation: { send in
            let nonConsumables = try await secureKeyValueStore.getNonConsumables()
            await send(.internalAction(.showPlay(nonConsumables.contains(.hideAds))))
          },
        )
      case .destination:
        return .none
      case .internalAction(.resetedSecureAllData):
        state.$isLaunchAtFirst.withLock { $0 = false }
        return .none
      case let .internalAction(.showPlay(isPurchasedHideAds)):
        // 非同期処理が入りこのアクションに来るのが遅くなってonAppearが再度呼ばれてしまうため画面を待機させておく
        state.destination = .play(
          .init(
            isPurchasedHideAds: isPurchasedHideAds,
          )
        )
        return .none
      }
    }
    .ifLet(\.destination, action: \.destination) {
      Destination.body
    }
  }
}

// MARK: - RootFeature.Destination.State Equatable
extension RootFeature.Destination.State: Equatable {}

// MARK: - RootFeature.Destination.State Sendable
extension RootFeature.Destination.State: Sendable {}

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  @Bindable public var store: StoreOf<RootFeature>

  // MARK: - Body
  public var body: some View {
    if let destination = store.scope(\.destination, action: \.destination) {
      switch destination.case {
      case let .appInfo(store):
        AppInfoPage(store: store)
      case let .consent(store):
        ConsentPage(store: store)
      case let .signInAnonymously(store):
        SignInAnonymouslyPage(store: store)
      case let .migrateV320(store):
        MigrateV320Page(store: store)
      case let .play(store):
        PlayPage(store: store)
      }
    } else {
      Text("")
        .task {
          store.send(.onAppear)
        }
        .analyticsScreen(
          screenName: .root,
          extraParameters: [
            "is_launch_at_first": AnyHashableSendable(stringLiteral: "\(store.isLaunchAtFirst)"),
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
