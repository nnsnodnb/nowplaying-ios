//
//  TestTwitterAccountManageFeaturePrepareLogin.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTwitterAccountManageFeaturePrepareLogin {
  @Test
  func testFreeTwitterLoginCountIsZero() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.prepareLogin) {
      $0.alert = AlertState(
        title: {
          TextState(.watchingAnAdIsRequiredToAddAnAccount)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.cancel)
            },
          )
          ButtonState(
            action: .openRewardedAd,
            label: {
              TextState(.watch)
            },
          )
        },
        message: {
          TextState(.pleaseCooperateAsRetrievingUserInformationIncursCosts)
        },
      )
    }
  }

  @Test
  func testFreeTwitterLoginCountIsNotEqualZero() async throws {
    await withDependencies {
      $0.twitterOAuth.getAuthenticateURL = { URL(string: "https://testserver/oauth/authorize")! }
    } operation: {
      @Shared(.appStorage(.freeTwitterLoginCount))
      var freeTwitterLoginCount = 1

      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.prepareLogin)
      await store.receive(\.oauth) {
        $0.oauthURL = URL(string: "https://testserver/oauth/authorize")!
      }
    }
  }
}
