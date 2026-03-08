//
//  TestTwitterSettingFeatureChangedAttachImageType.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeatureChangedAttachImageType {
  @Test
  func testDefaultToArtwork() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork))
  }

  @Test
  func testScreenShotToArtwork() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(
        attachImageType: .screenShot,
      ),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork)) {
      $0.$attachImageType.withLock { $0 = .onlyArtwork }
    }
  }

  @Test
  func testDefaultToScreenShot() async throws {
    let store = TestStore(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.screenShot)) {
      $0.$attachImageType.withLock { $0 = .screenShot }
    }
  }
}
