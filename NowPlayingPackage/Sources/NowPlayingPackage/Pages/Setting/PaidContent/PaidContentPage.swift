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
  public struct State: Equatable, Sendable {
    public var initialized = false
    public var freeTicketAdUnitID = ""
    public var isLoading = false
    public var isPurchasedHideAds = false
    public var isPurchasedAutoTweet = false
    public var postTickets: [PostTicket] = []
    public var availablePostTicket: AvailablePostTicket = .initial
    public var isLoadingPostTicket = true
    @Shared(.appStorage(.earnFreeTicketDate))
    public var earnFreeTicketDate: Date?
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case purchaseNonConsumable(NonConsumable)
    case restorePurchases
    case showAlertBeforeAds
    case purchasePostTicket(PostTicket)
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
      case setPostTickets([PostTicket], AvailablePostTicket)
      case updateAvailablePostTicket(AvailablePostTicket)
      case earnFreeTicket
      case paidNonConsumable(String)
      case paidPostTicket(PostTicket)
      case paidCheer(String)
      case failedPay(String, String?)
      case userCancelled
      case restored([NonConsumable])
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case close
      case watchAds
    }
  }

  // MARK: - Dependency
  @Dependency(\.adUnit)
  private var adUnit
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.apiClient)
  private var apiClient
  @Dependency(\.calendar)
  private var calendar
  @Dependency(\.date)
  private var date
  @Dependency(\.revenueCat)
  private var revenueCat
  @Dependency(\.rewardedAd)
  private var rewardedAd
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard !state.initialized else { return .none }
        state.initialized = true
        state.freeTicketAdUnitID = adUnit.getFreePostTicketRewardAdUnitID()
        return .run(
          operation: { send in
            await send(.internalAction(.getNonConsumable))
            let postTickets = try await apiClient.getPostTickets()
            let availablePostTicket = try await secureKeyValueStore.getAvailablePostTicket()
            await send(.internalAction(.setPostTickets(postTickets, availablePostTicket)))
          },
        )
      case let .purchaseNonConsumable(nonConsumable):
        state.isLoading = true
        return .run(
          operation: { send in
            switch nonConsumable {
            case .hideAds:
              try await revenueCat.purchaseHideAds()
              await analytics.logEvent(.purchasedNonConsumableContent("hide_banner_ads"))
              await analytics.setUserProperty(.hideBannerAds)
              await send(.delegate(.hideAds))
            case .autoTweet:
              try await revenueCat.purchaseAutoTweet()
              await analytics.logEvent(.purchasedNonConsumableContent("auto_tweet"))
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
                await analytics.setUserProperty(.hideBannerAds)
              }
            }
            await send(.internalAction(.restored(Array(nonConsumables))))
            await analytics.logEvent(.restoredPaidContent)
          },
          catch: { _, send in
            await send(.internalAction(.failedPay("購入に失敗しました", nil)))
          },
        )
      case .showAlertBeforeAds:
        // すでに当日中に見ている場合はスキップする
        let title: String
        let message: (() -> TextState)?

        if let earnFreeTicketDate = state.earnFreeTicketDate,
           calendar.isDate(earnFreeTicketDate, inSameDayAs: date.now) {
          title = "今日の無料チケットはすでに獲得済みです"
          message = nil
        } else {
          title = "広告を見て無料チケットを獲得しますか？"
          message = { TextState("視聴できるのは1日1回までです") }
        }
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            if message != nil {
              ButtonState(
                role: .cancel,
                label: {
                  TextState("キャンセル")
                },
              )
              ButtonState(
                action: .watchAds,
                label: {
                  TextState("視聴する")
                },
              )
            } else {
              ButtonState(
                action: .close,
                label: {
                  TextState("閉じる")
                },
              )
            }
          },
          message: message,
        )
        return .none
      case let .purchasePostTicket(postTicket):
        state.isLoading = true
        return .run(
          operation: { [availablePostTicket = state.availablePostTicket] send in
            try await revenueCat.purchasePostTicket(postTicket)
            await send(.internalAction(.paidPostTicket(postTicket)))
            await analytics.logEvent(.purchasedPostTicket(postTicket.ticketCount, availablePostTicket))
            var availablePostTicket = try await secureKeyValueStore.getAvailablePostTicket()
            availablePostTicket.increasePurchasedCount(amount: postTicket.ticketCount)
            try await secureKeyValueStore.setAvailablePostTicket(availablePostTicket)
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
      case .buyMeACoffee:
        state.isLoading = true
        return .run(
          operation: { send in
            try await revenueCat.buyMeACoffee()
            await send(.internalAction(.paidCheer("コーヒー")))
            await analytics.logEvent(.purchasedBuyMeACoffee)
            await analytics.setUserProperty(.kindUser(true))
          },
          catch: { error, send in
            guard let error = error as? RevenueCatClient.Error,
                  error != .userCancelled else {
              await send(.internalAction(.userCancelled))
              return
            }
            await send(.internalAction(.failedPay("購入に失敗しました", "お気持ち感謝いたします")))
            await analytics.setUserProperty(.kindUser(false))
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
      case let .internalAction(.setPostTickets(postTickets, availablePostTicket)):
        state.postTickets = postTickets
        state.availablePostTicket = availablePostTicket
        state.isLoadingPostTicket = false
        return .none
      case let .internalAction(.updateAvailablePostTicket(availablePostTicket)):
        state.availablePostTicket = availablePostTicket
        return .none
      case .internalAction(.earnFreeTicket):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState("無料チケットを獲得しました")
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
        return .run(
          operation: { send in
            var availablePostTicket = try await secureKeyValueStore.getAvailablePostTicket()
            await analytics.logEvent(.getFreePostTicket(availablePostTicket))
            availablePostTicket.increaseFreeCount(amount: 1)
            try await secureKeyValueStore.setAvailablePostTicket(availablePostTicket)
            await send(.internalAction(.updateAvailablePostTicket(availablePostTicket)))
          },
        )
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
      case let .internalAction(.paidPostTicket(postTicket)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState("投稿チケット\(postTicket.ticketCount)枚を購入しました")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("了解")
              },
            )
          },
          message: {
            TextState("ご購入ありがとうございます！！")
          }
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
      case .alert(.presented(.watchAds)):
        state.isLoading = true
        state.$earnFreeTicketDate.withLock { $0 = date.now }
        return .run(
          operation: { [state] send in
            await analytics.logEvent(.showGettingFreePostTicketAds(state.availablePostTicket))
            try await rewardedAd.load(state.freeTicketAdUnitID)
            let result = try await rewardedAd.show(state.freeTicketAdUnitID)
            guard result > 0 else { return }
            await send(.internalAction(.earnFreeTicket))
          },
        )
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
      .task {
        store.send(.onAppear)
      }
      .alert($store.scope(state: \.$alert, action: \.alert))
      .progress(store.isLoading)
      .analyticsScreen(screenName: .paidContent)
  }

  private var list: some View {
    List {
      nonConsumableSection
      consumableSection
      cheerSection
    }
  }

  @ViewBuilder private var nonConsumableSection: some View {
    // if !store.isPurchasedHideAds || !store.isPurchasedAutoTweet {
    if !store.isPurchasedHideAds {
      Section(
        content: {
          hideAdsRow
          // autoTweetRow
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
        Text("無料チケット: \(store.availablePostTicket.remainingFreeCount)枚")
        earnFreeTicketButtonRow
        Text("有料チケット: \(store.availablePostTicket.remainingPurchasedCount)枚")
        if store.isLoadingPostTicket {
          ProgressView()
            .frame(maxWidth: .infinity)
            .progressViewStyle(.circular)
        } else {
          ForEach(store.postTickets) { postTicket in
            postTicketRow(
              action: {
                store.send(.purchasePostTicket(postTicket))
              },
              postTicket: postTicket,
            )
          }
        }
      },
      header: {
        Text("消費コンテンツ")
      },
      footer: {
        VStack(alignment: .leading, spacing: 2) {
          Text("投稿チケットの消費について以下のルールに従います。")
          Text("1. 無料チケットから優先して消費されます。")
          Text("2. 投稿チケットはXへのポスト時のみ消費されます。")
          Text("3. 画像アップロードおよびテキスト投稿は、それぞれ独立した処理として扱われ、成功時に1枚ずつ消費されます。")
          Text("4. 画像アップロード成功後にテキスト投稿が失敗した場合、画像分の1枚のみ消費されます。")
          Text("5. 画像・テキストの両方が成功した場合は合計2枚消費されます。")
          Text("6. 各処理は「成功したもののみ」チケットが消費されます。")
        }
      },
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
      priceRow(
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
        price: 320,
      )
    }
  }

  @ViewBuilder private var autoTweetRow: some View {
    if !store.isPurchasedAutoTweet {
      priceRow(
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
        price: 0,
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

  private var earnFreeTicketButtonRow: some View {
    ButtonRow(
      action: {
        store.send(.showAlertBeforeAds)
      },
      title: "無料チケットを獲得する",
      icon: {
        Image(systemSymbol: .ticketFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.green)
      },
    )
  }

  private func postTicketRow(
    action: @escaping @MainActor () -> Void,
    postTicket: PostTicket,
  ) -> some View {
    priceRow(
      action: action,
      title: "投稿チケット (\(postTicket.ticketCount)枚)",
      icon: {
        Image(systemSymbol: .ticketFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.orange)
      },
      price: postTicket.price,
      discount: postTicket.discount,
    )
  }

  private var buyMeACoffeeRow: some View {
    priceRow(
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
      price: 300,
    )
  }

  private func priceRow(
    action: @escaping @MainActor () -> Void,
    title: String,
    @ViewBuilder icon: @escaping @MainActor () -> some View,
    price: Int? = nil,
    discount: String? = nil,
  ) -> some View {
    Button(
      action: action,
      label: {
        HStack(alignment: .center, spacing: 0) {
          Label(
            title: {
              VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if let discount {
                  Text("\(discount)OFF")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
              }
              .foregroundStyle(Color.primary)
            },
            icon: icon,
          )
          Spacer()
          if let price {
            Text("\(price)円")
              .foregroundStyle(Color.secondary)
          }
        }
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
