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
            await send(.internalAction(.failedPay(String(localized: .purchaseFailed), nil)))
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
            await send(.internalAction(.failedPay(String(localized: .purchaseFailed), nil)))
          },
        )
      case .showAlertBeforeAds:
        // すでに当日中に見ている場合はスキップする
        let title: String
        let message: (() -> TextState)?

        if let earnFreeTicketDate = state.earnFreeTicketDate,
           calendar.isDate(earnFreeTicketDate, inSameDayAs: date.now) {
          title = String(localized: .todaysFreeTicketHasAlreadyBeenClaimed)
          message = nil
        } else {
          title = String(localized: .wouldYouLikeToWatchAnAdToGetAFreeTicket)
          message = { TextState(.youCanWatchOncePerDay) }
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
                  TextState(.cancel)
                },
              )
              ButtonState(
                action: .watchAds,
                label: {
                  TextState(.watch)
                },
              )
            } else {
              ButtonState(
                action: .close,
                label: {
                  TextState(.close)
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
            await send(.internalAction(.failedPay(String(localized: .purchaseFailed), nil)))
          },
        )
      case .buyMeACoffee:
        state.isLoading = true
        return .run(
          operation: { send in
            try await revenueCat.buyMeACoffee()
            await send(.internalAction(.paidCheer(String(localized: .coffee))))
            await analytics.logEvent(.purchasedBuyMeACoffee)
            await analytics.setUserProperty(.kindUser(true))
          },
          catch: { error, send in
            guard let error = error as? RevenueCatClient.Error,
                  error != .userCancelled else {
              await send(.internalAction(.userCancelled))
              return
            }
            await send(.internalAction(
              .failedPay(String(localized: .purchaseFailed), String(localized: .thankYouForYourSupport))
            ))
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
            TextState(.freeTicketsAcquired)
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
            TextState(.thankYouForYourPurchase)
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
            TextState(.purchased(title))
          },
        )
        return .none
      case let .internalAction(.paidPostTicket(postTicket)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(.purchasedPostingTickets(postTicket.ticketCount))
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.okay)
              },
            )
          },
          message: {
            TextState(.thankYouForYourPurchase)
          }
        )
        return .none
      case let .internalAction(.paidCheer(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(.thankYouForYourSupport)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.keepItUp)
              },
            )
          },
          message: {
            TextState(.sentToTheDeveloper(title))
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
                TextState(.close)
              },
            )
          },
          message: alertMessage,
        )
        return .none
      case let .internalAction(.restored(nonConsumables)):
        let title: String
        if nonConsumables.isEmpty {
          title = String(localized: .thereAreNoPurchasesToRestore)
        } else {
          title = String(localized: .purchaseRestorationHasBeenCompleted)
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
                TextState(.close)
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
      .navigationTitle(.paidContent)
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
          Text(.nonConsumableContent)
        },
      )
    }
  }

  private var consumableSection: some View {
    Section(
      content: {
        Text(.freeTickets(store.availablePostTicket.remainingFreeCount))
        earnFreeTicketButtonRow
        Text(.paidTickets(store.availablePostTicket.remainingPurchasedCount))
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
        Text(.consumableContent)
      },
      footer: {
        VStack(alignment: .leading, spacing: 2) {
          Text(.theFollowingRulesApplyToTheConsumptionOfPostingTickets)
          Text(._1FreeTicketsWillBeUsedFirst)
          Text(._2PostingTicketsAreOnlyConsumedWhenPostingToX)
          Text(._3ImageUploadsAndTextPostsAreTreatedAsSeparateProcessesAndOneTicketIsConsumedForEachUponSuccess)
          Text(._4IfTheImageUploadSucceedsButTheTextPostFailsOnlyOneTicketForTheImageIsConsumed)
          Text(._5IfBothTheImageAndTextSucceedATotalOfTwoTicketsAreConsumed)
          Text(._6TicketsAreOnlyConsumedForProcessesThatSucceed)
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
        Text(.supportContent)
      },
    )
  }

  @ViewBuilder private var hideAdsRow: some View {
    if !store.isPurchasedHideAds {
      priceRow(
        action: {
          store.send(.purchaseNonConsumable(.hideAds))
        },
        title: String(localized: .removeBannerAds),
        icon: {
          Image(systemSymbol: .nosignAppFill)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.red)
        },
        price: String(localized: .yen(320)),
      )
    }
  }

  @ViewBuilder private var autoTweetRow: some View {
    if !store.isPurchasedAutoTweet {
      priceRow(
        action: {
          store.send(.purchaseNonConsumable(.autoTweet))
        },
        title: String(localized: .removeBannerAds),
        icon: {
          Image(systemSymbol: .paperplaneCircleFill)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color(UIColor.systemCyan))
        },
        price: "0",
      )
    }
  }

  private var restoreRow: some View {
    ButtonRow(
      action: {
        store.send(.restorePurchases)
      },
      title: String(localized: .restorePurchases),
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
      title: String(localized: .getFreeTickets),
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
      title: String(localized: .postTicketTickets(postTicket.ticketCount)),
      icon: {
        Image(systemSymbol: .ticketFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.orange)
      },
      price: postTicket.localizedPrice.getLocalePrice(),
      discount: postTicket.discount,
    )
  }

  private var buyMeACoffeeRow: some View {
    priceRow(
      action: {
        store.send(.buyMeACoffee)
      },
      title: String(localized: .buyMeACoffee),
      icon: {
        Image(systemSymbol: .cupAndHeatWavesFill)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.brown)
      },
      price: String(localized: .yen(300))
    )
  }

  private func priceRow(
    action: @escaping @MainActor () -> Void,
    title: String,
    @ViewBuilder icon: @escaping @MainActor () -> some View,
    price: String? = nil,
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
            Text(price)
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
