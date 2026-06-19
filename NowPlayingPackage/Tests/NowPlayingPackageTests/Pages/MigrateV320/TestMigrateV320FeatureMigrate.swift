//
//  TestMigrateV320FeatureMigrate.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/05/16.
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
struct TestMigrateV320FeatureMigrate {
  @Test
  func testIt() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let oauthToken = try Stub.make(TwitterOAuthToken.self)

    await withDependencies {
      $0.functions.migrateTwitterUserProfiles = { migrations in
        #expect(migrations.count == 1)
        #expect(migrations[0].twitterAccount == twitterAccount)
        #expect(migrations[0].refreshToken == oauthToken.refreshToken)
      }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.getTwitterOAuthToken = { _ in oauthToken }
      $0.secureKeyValueStore.removeTwitterOAuthToken = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.migrate) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.migrated) {
        $0.$migratedV320.withLock { $0 = true }
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testTwitterAccountIsEmpty() async throws {
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [] }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.migrate) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.migrated) {
        $0.$migratedV320.withLock { $0 = true }
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testTwitterOAuthTokenIsNil() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.getTwitterOAuthToken = { _ in nil }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.migrate) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.migrated) {
        $0.$migratedV320.withLock { $0 = true }
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testIsAlreadyMigratedV320() async throws {
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      @Shared(.appStorage(.migratedV320))
      var migratedV320 = true

      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.migrate)
      await store.receive(\.internalAction.migrated)
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testFailedMigrate() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let oauthToken = try Stub.make(TwitterOAuthToken.self)

    struct Error: Swift.Error {
    }

    await withDependencies {
      $0.functions.migrateTwitterUserProfiles = { migrations in
        #expect(migrations.count == 1)
        #expect(migrations[0].twitterAccount == twitterAccount)
        #expect(migrations[0].refreshToken == oauthToken.refreshToken)
        throw Error()
      }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.getTwitterOAuthToken = { _ in oauthToken }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.migrate) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.failedMigrate) {
        $0.isLoading = false
        $0.failedCount = 1
        $0.alert = AlertState(
          title: {
            TextState(.failedMigrateData)
          },
          actions: {
            ButtonState(
              action: .retry,
              label: {
                TextState(.retry)
              },
            )
          },
        )
      }
    }
  }
}
