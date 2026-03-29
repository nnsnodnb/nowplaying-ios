//
//  TestAppInfoFetchAppInfo.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestAppInfoFetchAppInfo {
  @Test
  func testIt() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: "1.0.0")
      $0.set(\.latest, value: "1.0.0")
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.shortVersionString = { "1.0.0" }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.completed)
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testToUpdateRequired() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: "1.0.1")
      $0.set(\.require, value: "1.0.1")
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.shortVersionString = { "1.0.0" }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.updateRequired) {
        $0.viewState = .updateRequire
      }
    }
  }

  @Test
  func testToUpdateAvailable() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: "1.0.0")
      $0.set(\.latest, value: "1.0.1")
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.shortVersionString = { "1.0.0" }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.updateAvailable) {
        $0.viewState = .updateAvailable
      }
    }
  }
}
