//
//  TestRootFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestRootFeatureOnAppear {
  @Test
  func testIsEmptyNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showPlay, false) {
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testHasAutoTweet() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showPlay, false) {
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testHasHideAds() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showPlay, true) {
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }

  @Test
  func testHasAllNonConsumables() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds, .autoTweet] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.showPlay, true) {
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }
}
