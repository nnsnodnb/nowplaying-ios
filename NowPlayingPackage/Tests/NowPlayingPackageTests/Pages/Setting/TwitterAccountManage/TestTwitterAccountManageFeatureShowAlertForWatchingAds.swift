//
//  TestTwitterAccountManageFeatureShowAlertForWatchingAds.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureShowAlertForWatchingAds {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.showAlertForWatchingAds) {
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
}
