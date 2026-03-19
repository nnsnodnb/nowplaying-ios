//
//  TestSocialServiceSettingFeatureChangedIsAttachImage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestSocialServiceSettingFeatureChangedIsAttachImage {
  @Test
  func testTwitterDefaultToIsAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true))
  }

  @Test
  func testBlueskyDefaultToIsAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true))
  }

  @Test
  func testTwitterToIsAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
        isTwitterAttachImage: false,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true)) {
      $0.$isTwitterAttachImage.withLock { $0 = true }
    }
  }

  @Test
  func testBlueskyToIsAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
        isBlueskyAttachImage: false,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(true)) {
      $0.$isBlueskyAttachImage.withLock { $0 = true }
    }
  }

  @Test
  func testTwitterToIsNotAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .twitter,
        isTwitterAttachImage: true,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(false)) {
      $0.$isTwitterAttachImage.withLock { $0 = false }
    }
  }

  @Test
  func testBlueskyToIsNotAttachImage() async throws {
    let store = TestStore(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
        isTwitterAttachImage: true,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )

    await store.send(.changedIsAttachImage(false)) {
      $0.$isBlueskyAttachImage.withLock { $0 = false }
    }
  }
}
