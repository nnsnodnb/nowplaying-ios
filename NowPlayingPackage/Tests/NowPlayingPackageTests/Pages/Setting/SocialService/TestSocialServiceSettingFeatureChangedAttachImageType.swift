//
//  TestSocialServiceSettingFeatureChangedAttachImageType.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestSocialServiceSettingFeatureChangedAttachImageType {
  @Test
  func testTwitterDefaultToArtwork() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork))
  }

  @Test
  func testBlueskyDefaultToArtwork() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork))
  }

  @Test
  func testTwitterScreenShotToArtwork() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
        twitterAttachImageType: .screenShot,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork)) {
      $0.$twitterAttachImageType.withLock { $0 = .onlyArtwork }
    }
  }

  @Test
  func testBlueskyScreenShotToArtwork() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
        blueskyAttachImageType: .screenShot,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.onlyArtwork)) {
      $0.$blueskyAttachImageType.withLock { $0 = .onlyArtwork }
    }
  }

  @Test
  func testTwitterDefaultToScreenShot() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.screenShot)) {
      $0.$twitterAttachImageType.withLock { $0 = .screenShot }
    }
  }

  @Test
  func testBlueskyDefaultToScreenShot() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedAttachImageType(.screenShot)) {
      $0.$blueskyAttachImageType.withLock { $0 = .screenShot }
    }
  }
}
