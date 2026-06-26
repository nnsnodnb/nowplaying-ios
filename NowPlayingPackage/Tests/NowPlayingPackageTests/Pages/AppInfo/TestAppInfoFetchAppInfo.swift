//
//  TestAppInfoFetchAppInfo.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import CommonModule
import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestAppInfoFetchAppInfo {
  @Test
  func testIt() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: 1)
      $0.set(\.latest, value: 1)
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.buildVersion = { 1 }
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
      $0.set(\.require, value: 2)
      $0.set(\.latest, value: 2)
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.buildVersion = { 1 }
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
  func testToUpdateAvailableYetSkipped() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: 1)
      $0.set(\.latest, value: 2)
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.buildVersion = { 1 }
    } operation: {
      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.updateAvailable, 2) {
        $0.updateAvailableBuild = 2
        $0.viewState = .updateAvailable
      }
    }
  }

  @Test
  func testToUpdateAvailableSkippedAvailableVersionIsLatest() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: 1)
      $0.set(\.latest, value: 2)
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.buildVersion = { 1 }
    } operation: {
      @Shared(.appStorage(.skippedUpdateBuild))
      var skippedUpdateBuild = 2

      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.updateAvailable, 2) {
        $0.updateAvailableBuild = 2
      }
      await store.receive(\.delegate.completed)
    }
  }

  @Test
  func testToUpdateAvailableSkippedAvailableVersionIsNotLatest() async throws {
    let appVersion = try Stub.make(AppInfo.AppVersion.self) {
      $0.set(\.require, value: 1)
      $0.set(\.latest, value: 2)
    }
    let appInfo = AppInfo(appVersion: appVersion)

    await withDependencies {
      $0.apiClient.getAppInfo = { appInfo }
      $0.bundle.buildVersion = { 1 }
    } operation: {
      @Shared(.appStorage(.skippedUpdateBuild))
      var skippedUpdateBuild = 1

      let store = TestStore(
        initialState: AppInfoFeature.State(),
        reducer: {
          AppInfoFeature()
        },
      )

      await store.send(.fetchAppInfo)
      await store.receive(\.internalAction.updateAvailable, 2) {
        $0.updateAvailableBuild = 2
        $0.viewState = .updateAvailable
      }
    }
  }
}
