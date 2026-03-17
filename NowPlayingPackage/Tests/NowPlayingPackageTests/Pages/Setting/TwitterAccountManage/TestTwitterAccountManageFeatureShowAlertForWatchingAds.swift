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
          TextState("アカウントを追加するには広告の視聴が必要です。")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("キャンセル")
            },
          )
          ButtonState(
            action: .openRewardedAd,
            label: {
              TextState("視聴する")
            },
          )
        },
        message: {
          TextState("ユーザー情報を取得するためにコストが発生するためご協力お願いします。")
        },
      )
    }
  }
}
