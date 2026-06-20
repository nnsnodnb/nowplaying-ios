//
//  TestMigrateV320FeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/19.
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
struct TestMigrateV320FeatureOnAppear {
  @Test
  func testIt() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    await withDependencies {
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        }
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.fetchedTwitterAccounts) {
        $0.twitterAccounts = [twitterAccount]
      }
    }
  }

  @Test
  func testMigrateV320YetIsEmptyTwitterAccounts() async throws {
    let mainQueue = DispatchQueue.test

    @Shared(.appStorage(.migratedV320))
    var migratedV320 = false

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [] }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        }
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.migrated) {
        $0.$migratedV320.withLock { $0 = true }
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testAlreadyMigratedV320() async throws {
    let mainQueue = DispatchQueue.test

    @Shared(.appStorage(.migratedV320))
    var migratedV320 = true

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        }
      )

      await store.send(.onAppear)
      await store.receive(\.internalAction.migrated)
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }
}
