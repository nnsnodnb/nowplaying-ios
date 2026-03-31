//
//  TestPaidContentFeaturePurchasePostTicket.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPaidContentFeaturePurchasePostTicket {
  @Test
  func testIt() async throws {
    let postTicket = try Stub.make(PostTicket.self) {
      $0.set(\.ticketCount, value: 30)
    }
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingPurchasedCount, value: 29)
      $0.set(\.totalPurchasedCount, value: 160)
    }

    await withDependencies {
      $0.revenueCat.purchasePostTicket = { _ in }
      $0.secureKeyValueStore.getAvailablePostTicket = { availablePostTicket }
      $0.secureKeyValueStore.setAvailablePostTicket = { object in
        #expect(object.remainingPurchasedCount == 59)
        #expect(object.totalPurchasedCount == 190)
      }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.purchasePostTicket(postTicket)) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.paidPostTicket, postTicket) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState(.purchasedPostingTickets(30))
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
      }
    }
  }

  @Test(
    .dependencies {
      $0.revenueCat.purchasePostTicket = { _ in throw RevenueCatClient.Error.userCancelled }
    }
  )
  func testUserCancelled() async throws {
    let postTicket = try Stub.make(PostTicket.self)

    let store = TestStore(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    )

    await store.send(.purchasePostTicket(postTicket)) {
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
    let postTicket = try Stub.make(PostTicket.self)

    await withDependencies {
      $0.revenueCat.purchasePostTicket = { _ in throw error }
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.purchasePostTicket(postTicket)) {
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
        )
      }
    }
  }
}
