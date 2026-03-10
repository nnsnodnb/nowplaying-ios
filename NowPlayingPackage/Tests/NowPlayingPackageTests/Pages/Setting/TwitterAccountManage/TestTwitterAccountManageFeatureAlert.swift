//
//  TestTwitterAccountManageFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureAlert {
  @Test
  func testAlertDismiss() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        alert: AlertState(
          title: {
            TextState("テスト")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
