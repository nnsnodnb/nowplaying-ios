//
//  TestPaidContentFeatureRestorePurchases.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPaidContentFeatureRestorePurchases {
  @Test(
    .dependencies {
      $0.revenueCat.restorePurchases = { [] }
    }
  )
  func testRestoreIsEmpty() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.restorePurchases) {
      $0.isLoading = true
    }
    await store.receive(\.internalAction.restored, []) {
      $0.isLoading = false
      $0.alert = AlertState(
        title: {
          TextState("復元する購入が何もありません")
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

  @Test(
    .dependencies {
      $0.revenueCat.restorePurchases = { [.hideAds, .autoTweet] }
      $0.secureKeyValueStore.addNonConsumable = { _ in }
    }
  )
  func testRestoreIsNotEmpty() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.restorePurchases) {
      $0.isLoading = true
    }
    await store.receive(\.delegate.hideAds)
    await store.receive(\.internalAction.restored) {
      $0.isLoading = false
      $0.alert = AlertState(
        title: {
          TextState("購入の復元が完了しました")
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
    await store.receive(\.internalAction.setNonConsumable) {
      $0.isPurchasedHideAds = true
      $0.isPurchasedAutoTweet = true
    }
  }
}
