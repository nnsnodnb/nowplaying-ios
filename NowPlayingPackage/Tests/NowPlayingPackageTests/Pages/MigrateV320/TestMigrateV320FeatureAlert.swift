//
//  TestMigrateV320FeatureAlert.swift
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
struct TestMigrateV320FeatureAlert {
  @Test
  func testIt() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let oauthToken = try Stub.make(TwitterOAuthToken.self)

    await withDependencies {
      $0.functions.migrateTwitterUserProfiles = { _ in }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.secureKeyValueStore.getTwitterOAuthToken = { _ in oauthToken }
      $0.secureKeyValueStore.removeTwitterOAuthToken = { _ in }
    } operation: {
      let store = TestStore(
        initialState: MigrateV320Feature.State(
          alert: .init(
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
          ),
        ),
        reducer: {
          MigrateV320Feature()
        },
      )

      await store.send(.alert(.presented(.retry))) {
        $0.alert = nil
      }
      await mainQueue.advance(by: .milliseconds(400))
      await store.receive(\.migrate) {
        $0.isLoading = true
        $0.$migratedV320.withLock { $0 = true }
      }
      await store.receive(\.internalAction.migrated) {
        $0.isLoading = false
      }
      await mainQueue.advance(by: .milliseconds(200))
      await store.receive(\.delegate.completed)
    }
  }
}
