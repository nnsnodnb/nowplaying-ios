//
//  TestPaidContentFeaturePurchaseNonConsumable.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPaidContentFeaturePurchaseNonConsumable {
  @Test(
    .dependencies {
      $0.revenueCat.purchaseHideAds = {}
      $0.secureKeyValueStore.addNonConsumable = { #expect($0 == .hideAds) }
    }
  )
  func testHideAds() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.purchaseNonConsumable(.hideAds)) {
      $0.isLoading = true
    }
    await store.receive(\.delegate.hideAds)
    await store.receive(\.internalAction.paidNonConsumable, "バナー広告削除") {
      $0.isLoading = false
      $0.alert = AlertState(
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
          TextState("【バナー広告削除】を購入しました")
        },
      )
    }
    await store.receive(\.internalAction.setNonConsumable, [.hideAds]) {
      $0.isPurchasedHideAds = true
    }
  }

  @Test(
    .dependencies {
      $0.revenueCat.purchaseAutoTweet = {}
      $0.secureKeyValueStore.addNonConsumable = { #expect($0 == .autoTweet) }
    }
  )
  func testAutoTweet() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.purchaseNonConsumable(.autoTweet)) {
      $0.isLoading = true
    }
    await store.receive(\.internalAction.paidNonConsumable, "自動ツイート") {
      $0.isLoading = false
      $0.alert = AlertState(
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
          TextState("【自動ツイート】を購入しました")
        },
      )
    }
    await store.receive(\.internalAction.setNonConsumable, [.autoTweet]) {
      $0.isPurchasedAutoTweet = true
    }
  }

  @Test(
    arguments: [NonConsumable.hideAds, NonConsumable.autoTweet],
  )
  func testUserCancelled(nonConsumable: NonConsumable) async throws {
    await withDependencies {
      switch nonConsumable {
      case .hideAds:
        $0.revenueCat.purchaseHideAds = { throw RevenueCatClient.Error.userCancelled }
      case .autoTweet:
        $0.revenueCat.purchaseAutoTweet = { throw RevenueCatClient.Error.userCancelled }
      }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.purchaseNonConsumable(nonConsumable)) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.userCancelled) {
        $0.isLoading = false
      }
    }
  }

  @Test(
    arguments: [RevenueCatClient.Error.internalError, RevenueCatClient.Error.purchaseError],
    [NonConsumable.hideAds, NonConsumable.autoTweet],
  )
  func testError(error: RevenueCatClient.Error, nonConsumable: NonConsumable) async throws {
    await withDependencies {
      switch nonConsumable {
      case .hideAds:
        $0.revenueCat.purchaseHideAds = { throw error }
      case .autoTweet:
        $0.revenueCat.purchaseAutoTweet = { throw error }
      }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.purchaseNonConsumable(nonConsumable)) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.failedPay) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("購入に失敗しました")
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
      }
    }
  }
}
