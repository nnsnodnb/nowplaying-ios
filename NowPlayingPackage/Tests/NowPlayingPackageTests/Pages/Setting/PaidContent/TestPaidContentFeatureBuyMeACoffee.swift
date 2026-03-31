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
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
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
    await store.receive(\.internalAction.paidCheer, String(localized: .coffee)) {
      $0.isLoading = false
      $0.alert = AlertState(
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
          TextState(.sentToTheDeveloper(String(localized: .coffee)))
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
            TextState(.purchaseFailed)
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
            TextState(.thankYouForYourSupport)
          },
        )
      }
    }
  }
}
