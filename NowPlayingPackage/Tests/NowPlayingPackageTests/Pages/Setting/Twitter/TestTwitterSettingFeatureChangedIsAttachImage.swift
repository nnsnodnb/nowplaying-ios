//
//  TestTwitterSettingFeatureChangedIsAttachImage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeatureChangedIsAttachImage {
  @Test
  func testDefaultToIsAttachImage() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true))
  }

  @Test
  func testToIsAttachImage() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(
        isAttachImage: false,
      ),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true)) {
      $0.$isAttachImage.withLock { $0 = true }
    }
  }

  @Test
  func testToIsNotAttachImage() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(
        isAttachImage: true,
      ),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(false)) {
      $0.$isAttachImage.withLock { $0 = false }
    }
  }
}
