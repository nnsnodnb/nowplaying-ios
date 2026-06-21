//
//  TestMigrateV320FeatureForceContinueTheApp.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/20.
//

import CommonModule
import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestMigrateV320FeatureForceContinueTheApp {
  @Test
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    await withDependencies {
      $0.secureKeyValueStore.removeTwitterAccount = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(
          twitterAccounts: [twitterAccount],
        ),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.forceContinueTheApp)
      await store.receive(\.internalAction.deletedTwitterAccounts) {
        $0.$migratedV320.withLock { $0 = true }
        $0.$freeTwitterLoginCount.withLock { $0 = 1 }
      }
      await store.receive(\.delegate.completed)
    }
  }
}
