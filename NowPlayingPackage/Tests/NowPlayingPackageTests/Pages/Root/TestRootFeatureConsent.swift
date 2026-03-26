//
//  TestRootFeatureConsent.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureConsent {
  @Test
  func testConsentDelegateCompletedConsentIsEmptyNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          consent: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.consent(.delegate(.completedConsent)))
      await store.receive(\.internalAction.showPlay, false) {
        $0.consent = nil
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testConsentDelegateCompletedHasAutoTweet() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          consent: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.consent(.delegate(.completedConsent)))
      await store.receive(\.internalAction.showPlay, false) {
        $0.consent = nil
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testConsentDelegateCompletedHasHideAds() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          consent: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.consent(.delegate(.completedConsent)))
      await store.receive(\.internalAction.showPlay, true) {
        $0.consent = nil
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }

  @Test
  func testConsentDelegateCompletedHasAllNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds, .autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          consent: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.consent(.delegate(.completedConsent)))
      await store.receive(\.internalAction.showPlay, true) {
        $0.consent = nil
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }
}
