//
//  TestRootFeatureDestination.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/27.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestRootFeatureDestination {
  @Test
  func testDestinationAppInfoDelegateCompleted() async throws {
    let store = TestStore(
      initialState: RootFeature.State(
        destination: .appInfo(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.appInfo(.delegate(.completed)))) {
      $0.destination = .consent(.init())
    }
  }

  @Test
  func testDestinationConsentDelegateCompletedConsent() async throws {
    let store = TestStore(
      initialState: RootFeature.State(
        destination: .consent(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.consent(.delegate(.completedConsent)))) {
      $0.destination = .signInAnonymously(.init())
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedConsentIsEmptyNonConsumablesAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          destination: .signInAnonymously(.init()),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.destination(.signInAnonymously(.delegate(.completed))))
      await store.receive(\.internalAction.showPlay, false) {
        $0.destination = .play(
          .init(
            isPurchasedHideAds: false,
          )
        )
      }
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedConsentIsEmptyNonConsumablesAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    let store = TestStore(
      initialState: RootFeature.State(
        destination: .signInAnonymously(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.signInAnonymously(.delegate(.completed)))) {
      $0.destination = .migrateV320(.init())
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasAutoTweetAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.autoTweet] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          destination: .signInAnonymously(.init()),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.destination(.signInAnonymously(.delegate(.completed))))
      await store.receive(\.internalAction.showPlay, false) {
        $0.destination = .play(
          .init(
            isPurchasedHideAds: false,
          )
        )
      }
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasAutoTweetAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    let store = TestStore(
      initialState: RootFeature.State(
        destination: .signInAnonymously(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.signInAnonymously(.delegate(.completed)))) {
      $0.destination = .migrateV320(.init())
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasHideAdsAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          destination: .signInAnonymously(.init()),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.destination(.signInAnonymously(.delegate(.completed))))
      await store.receive(\.internalAction.showPlay, true) {
        $0.destination = .play(
          .init(
            isPurchasedHideAds: true,
          )
        )
      }
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasHideAdsAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    let store = TestStore(
      initialState: RootFeature.State(
        destination: .signInAnonymously(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.signInAnonymously(.delegate(.completed)))) {
      $0.destination = .migrateV320(.init())
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasAllNonConsumablesAndMigratedV320() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [.hideAds, .autoTweet] }
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: RootFeature.State(
          destination: .signInAnonymously(.init()),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.destination(.signInAnonymously(.delegate(.completed))))
      await store.receive(\.internalAction.showPlay, true) {
        $0.destination = .play(
          .init(
            isPurchasedHideAds: true,
          )
        )
      }
    }
  }

  @Test
  func testDestinationSigninAnonymouslyDelegateCompletedHasAllNonConsumablesAndNotMigratedV320() async throws {
    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    let store = TestStore(
      initialState: RootFeature.State(
        destination: .signInAnonymously(.init()),
      ),
      reducer: {
        RootFeature()
      },
    )

    await store.send(.destination(.signInAnonymously(.delegate(.completed)))) {
      $0.destination = .migrateV320(.init())
    }
  }

  @Test
  func testDestinationMigrateV320DelegateCompleted() async throws {
    await withDependencies {
      $0.secureKeyValueStore.getNonConsumables = { [] }
    } operation: {
      let store = TestStore(
        initialState: RootFeature.State(
          destination: .migrateV320(.init()),
        ),
        reducer: {
          RootFeature()
        },
      )

      await store.send(.destination(.migrateV320(.delegate(.completed))))
      await store.receive(\.internalAction.showPlay, false) {
        $0.destination = .play(
          .init(
            isPurchasedHideAds: false,
          )
        )
      }
    }
  }
}
