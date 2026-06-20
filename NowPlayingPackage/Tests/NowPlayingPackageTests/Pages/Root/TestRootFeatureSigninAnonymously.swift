//
//  TestRootFeatureSigninAnonymously.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/24.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestRootFeatureSigninAnonymously {
  @Test
  func testSigninAnonymouslyDelegateCompletedConsentIsEmptyNonConsumablesAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed)))
      await store.receive(\.internalAction.showPlay, false) {
        $0.signInAnonymously = nil
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedConsentIsEmptyNonConsumablesAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

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
      $0.migrateV320 = .init()
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAutoTweetAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.autoTweet] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed)))
      await store.receive(\.internalAction.showPlay, false) {
        $0.signInAnonymously = nil
        $0.play = .init(
          isPurchasedHideAds: false,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAutoTweetAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

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
      $0.migrateV320 = .init()
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasHideAdsAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed)))
      await store.receive(\.internalAction.showPlay, true) {
        $0.signInAnonymously = nil
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasHideAdsAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

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
      $0.migrateV320 = .init()
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAllNonConsumablesAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds, .autoTweet] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          signInAnonymously: .init(),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.signInAnonymously(.delegate(.completed)))
      await store.receive(\.internalAction.showPlay, true) {
        $0.signInAnonymously = nil
        $0.play = .init(
          isPurchasedHideAds: true,
        )
      }
    }
  }

  @Test
  func testSigninAnonymouslyDelegateCompletedHasAllNonConsumablesAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

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
      $0.migrateV320 = .init()
    }
  }
}
