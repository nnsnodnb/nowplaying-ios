//
//  TestAppInfoFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestAppInfoFeatureAlert {
  @Test
  func testPresentedRetry() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: "1.0.0")
      $0.set(\.latest, value: "1.0.0")
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.continuousClock = .immediate
      $0.bundle.shortVersionString = { "1.0.0" }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(
          alert: AlertState(
            title: {
              TextState("テスト")
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
        ),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.alert(.presented(.retry)))
      await store.receive(\.fetchAppInfo)
      await store.receive(\.internalAction.completed)
      await store.receive(\.delegate.completed)
    }
  }
}
