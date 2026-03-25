//
//  TestPaidContentFeatureBuyMeACoffee.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPaidContentFeatureBuyMeACoffee {
  @Test(
    .dependencies {
      $0.revenueCat.buyMeACoffee = {}
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.buyMeACoffee) {
      $0.isLoading = true
    }
    await store.receive(\.internalAction.paidCheer, "コーヒー") {
      $0.isLoading = false
      $0.alert = AlertState(
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
          TextState("開発者にコーヒーをプレゼントしました！")
        },
      )
    }
  }

  @Test(
    .dependencies {
      $0.revenueCat.buyMeACoffee = { throw RevenueCatClient.Error.userCancelled }
    }
  )
  func testUserCancelled() async throws {
    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.buyMeACoffee) {
      $0.isLoading = true
    }
    await store.receive(\.internalAction.userCancelled) {
      $0.isLoading = false
    }
  }

  @Test(
    arguments: [RevenueCatClient.Error.purchaseError, RevenueCatClient.Error.internalError],
  )
  func testError(error: RevenueCatClient.Error) async throws {
    await withDependencies {
      $0.revenueCat.buyMeACoffee = { throw error }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.buyMeACoffee) {
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
          message: {
            TextState("お気持ち感謝いたします")
          },
        )
      }
    }
  }
}
