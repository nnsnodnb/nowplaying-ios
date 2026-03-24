//
//  PaidContentPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
public struct PaidContentFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public var isLoading = false
    public var isPurchasedHideAds = false
    public var isPurchasedAutoTweet = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case purchaseNonConsumable(NonConsumable)
    case restorePurchases
    case buyMeACoffee
    case delegate(Delegate)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case hideAds
    }

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case getNonConsumable
      case setNonConsumable([NonConsumable])
      case paidNonConsumable(String)
      case paidCheer(String)
      case failedPay(String, String?)
      case userCancelled
      case restored([NonConsumable])
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable {
      case close
    }
  }

  // MARK: - Dependency
  @Dependency(\.revenueCat)
  private var revenueCat
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .send(.internalAction(.getNonConsumable))
      case let .purchaseNonConsumable(nonConsumable):
        state.isLoading = true
        return .run(
          operation: { send in
            switch nonConsumable {
            case .hideAds:
              try await revenueCat.purchaseHideAds()
              await send(.delegate(.hideAds))
            case .autoTweet:
              try await revenueCat.purchaseAutoTweet()
            }
            try await secureKeyValueStore.addNonConsumable(nonConsumable)
            await send(.internalAction(.paidNonConsumable(nonConsumable.description)))
            await send(.internalAction(.setNonConsumable([nonConsumable])))
          },
          catch: { error, send in
            guard let error = error as? RevenueCatClient.Error,
                  error != .userCancelled else {
              await send(.internalAction(.userCancelled))
              return
            }
            await send(.internalAction(.failedPay("購入に失敗しました", nil)))
          },
        )
      case .restorePurchases:
        state.isLoading = true
        return .run(
          operation: { send in
            let nonConsumables = try await revenueCat.restorePurchases()
            for nonConsumable in nonConsumables {
              try await secureKeyValueStore.addNonConsumable(nonConsumable)
              if nonConsumable == .hideAds {
                await send(.delegate(.hideAds))
              }
            }
            await send(.internalAction(.restored(Array(nonConsumables))))
          },
          catch: { _, send in
            await send(.internalAction(.failedPay("購入に失敗しました", nil)))
          },
        )
      case .buyMeACoffee:
        state.isLoading = true
        return .run(
          operation: { send in
            try await revenueCat.buyMeACoffee()
            await send(.internalAction(.paidCheer("コーヒー")))
          },
          catch: { error, send in
            guard let error = error as? RevenueCatClient.Error,
                  error != .userCancelled else {
              await send(.internalAction(.userCancelled))
              return
            }
            await send(.internalAction(.failedPay("購入に失敗しました", "お気持ち感謝いたします")))
          },
        )
      case .delegate:
        return .none
      case .internalAction(.getNonConsumable):
        return .run(
          operation: { send in
            let nonConsumables = try await secureKeyValueStore.getNonConsumables()
            await send(.internalAction(.setNonConsumable(nonConsumables)))
          },
        )
      case let .internalAction(.setNonConsumable(nonConsumables)):
        for nonConsumable in nonConsumables {
          switch nonConsumable {
          case .hideAds:
            state.isPurchasedHideAds = true
          case .autoTweet:
            state.isPurchasedAutoTweet = true
          }
        }
        return .none
      case let .internalAction(.paidNonConsumable(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState("ご購入ありがとうございます！")
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
            TextState("【\(title)】を購入しました")
          },
        )
        return .none
      case let .internalAction(.paidCheer(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState("応援ありがとうございます！")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("がんばれよ！")
              },
            )
          },
          message: {
            TextState("開発者に\(title)をプレゼントしました！")
          },
        )
        return .none
      case let .internalAction(.failedPay(title, message)):
        state.isLoading = false
        let alertMessage: (() -> TextState)?
        if let message {
          alertMessage = { TextState(message) }
        } else {
          alertMessage = nil
        }
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
          message: alertMessage,
        )
        return .none
      case let .internalAction(.restored(nonConsumables)):
        let title: String
        if nonConsumables.isEmpty {
          title = "復元する購入が何もありません"
        } else {
          title = "購入の復元が完了しました"
        }
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
        return nonConsumables.isEmpty ? .none : .send(.internalAction(.setNonConsumable(nonConsumables)))
      case .internalAction(.userCancelled):
        state.isLoading = false
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

public struct PaidContentPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PaidContentFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("有料コンテンツ")
      .interactiveDismissDisabled(true)
      .onAppear {
        store.send(.onAppear)
      }
      .alert($store.scope(state: \.alert, action: \.alert))
      .progress(store.isLoading)
  }

  private var list: some View {
    List {
      nonConsumableSection
      consumableSection
      cheerSection
    }
  }

  @ViewBuilder private var nonConsumableSection: some View {
    if !store.isPurchasedHideAds || !store.isPurchasedAutoTweet {
      Section(
        content: {
          hideAdsRow
          autoTweetRow
          restoreRow
        },
        header: {
          Text("非消費コンテンツ")
        },
      )
    }
  }

  private var consumableSection: some View {
    Section(
      content: {
      },
      header: {
        Text("消費コンテンツ")
      }
    )
  }

  private var cheerSection: some View {
    Section(
      content: {
        buyMeACoffeeRow
      },
      header: {
        Text("応援用コンテンツ")
      },
    )
  }

  @ViewBuilder private var hideAdsRow: some View {
    if !store.isPurchasedHideAds {
      ButtonRow(
        action: {
          store.send(.purchaseNonConsumable(.hideAds))
        },
        title: "バナー広告削除",
        icon: {
          Image(systemSymbol: .nosignAppFill)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.red)
        },
      )
    }
  }

  @ViewBuilder private var autoTweetRow: some View {
    if !store.isPurchasedAutoTweet {
      ButtonRow(
        action: {
          store.send(.purchaseNonConsumable(.autoTweet))
        },
        title: "自動ツイート",
        icon: {
          Image(systemSymbol: .paperplaneCircleFill)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color(UIColor.systemCyan))
        },
      )
    }
  }

  private var restoreRow: some View {
    ButtonRow(
      action: {
        store.send(.restorePurchases)
      },
      title: "購入を復元する",
      icon: {
        Image(systemSymbol: .purchasedCircleFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.yellow)
      },
    )
  }

  private var buyMeACoffeeRow: some View {
    ButtonRow(
      action: {
        store.send(.buyMeACoffee)
      },
      title: "コーヒーを買ってあげる",
      icon: {
        Image(systemSymbol: .cupAndHeatWavesFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.brown)
      },
    )
  }
}

#Preview {
  PaidContentPage(
    store: .init(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    ),
  )
}
