//
//  TestTwitterSettingFeatureCopyFormat.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterSettingFeatureCopyFormat {
  @Test(
    arguments: [
      TwitterSettingFeature.Action.CopyFormatType.songTitle,
      TwitterSettingFeature.Action.CopyFormatType.artist,
      TwitterSettingFeature.Action.CopyFormatType.album,
    ]
  )
  func testIt(copyFormatType: TwitterSettingFeature.Action.CopyFormatType) async throws {
    await withDependencies {
      $0.pasteboard.setString = {
        #expect($0 == copyFormatType.rawValue)
      }
    } operation: {
      let store = TestStore(
        initialState: TwitterSettingFeature.State(),
        reducer: {
          TwitterSettingFeature()
        },
      )

      await store.send(.copyFormat(copyFormatType))
    }
  }
}
