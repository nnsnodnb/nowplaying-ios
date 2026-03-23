//
//  TestSocialServiceSettingFeatureCopyFormat.swift
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
struct TestSocialServiceSettingFeatureCopyFormat {
  @Test(
    arguments: [CopyFormatType.songTitle, CopyFormatType.artist, CopyFormatType.album]
  )
  func testTwitter(copyFormatType: CopyFormatType) async throws {
    await withDependencies {
      $0.pasteboard.setString = {
        #expect($0 == copyFormatType.rawValue)
      }
    } operation: {
      let store = TestStore(
        initialState: SocialServiceSettingFeature.State(
          socialService: .twitter,
        ),
        reducer: {
          SocialServiceSettingFeature()
        },
      )

      await store.send(.copyFormat(copyFormatType))
    }
  }

  @Test(
    arguments: [CopyFormatType.songTitle, CopyFormatType.artist, CopyFormatType.album]
  )
  func testBluesky(copyFormatType: CopyFormatType) async throws {
    await withDependencies {
      $0.pasteboard.setString = {
        #expect($0 == copyFormatType.rawValue)
      }
    } operation: {
      let store = TestStore(
        initialState: SocialServiceSettingFeature.State(
          socialService: .bluesky,
        ),
        reducer: {
          SocialServiceSettingFeature()
        },
      )

      await store.send(.copyFormat(copyFormatType))
    }
  }
}
