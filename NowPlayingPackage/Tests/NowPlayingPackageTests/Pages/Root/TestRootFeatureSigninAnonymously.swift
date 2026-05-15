//
//  TestRootFeatureSigninAnonymously.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureSigninAnonymously {
  @Test
  func testSigninAnonymouslyDelegateCompletedConsentIsEmptyNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed))) {
        $0.signInAnonymously = nil
      }
      await store.receive(\.internalAction.showPlay, false) {
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAutoTweet() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed))) {
        $0.signInAnonymously = nil
      }
      await store.receive(\.internalAction.showPlay, false) {
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasHideAds() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed))) {
        $0.signInAnonymously = nil
      }
      await store.receive(\.internalAction.showPlay, true) {
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAllNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds, .autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed))) {
        $0.signInAnonymously = nil
      }
      await store.receive(\.internalAction.showPlay, true) {
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }
}
