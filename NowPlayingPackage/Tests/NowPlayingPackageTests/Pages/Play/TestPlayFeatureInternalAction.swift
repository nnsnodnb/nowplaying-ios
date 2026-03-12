//
//  TestPlayFeatureInternalAction.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/12.
//

import ComposableArchitecture
import Dependencies
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureInternalAction {
  @Test
  func testAuthorizationSuccess() async throws {
    let nowPlayingItem = StubMediaItem()

    await withDependencies {
      $0.mediaPlayer.nowPlayingItem = {
        AsyncStream {
          $0.yield(nowPlayingItem)
          $0.finish()
        }
      }
      $0.mediaPlayer.playbackState = {
        AsyncStream {
          $0.finish()
        }
      }
      $0.mediaPlayer.getNowPlayingArtwork = { _ in .init(systemSymbol: .photo) }
    } operation: {
      let store = TestStore(
        initialState: PlayFeature.State(),
        reducer: {
          PlayFeature()
        },
      )

      await store.send(.internalAction(.authorizationSuccess)) {
        $0.songName = "読み込み中..."
        $0.artistName = ""
      }
      await store.receive(\.internalAction.applyNowPlayingItem) {
        $0.songName = nowPlayingItem.title!
        $0.artistName = nowPlayingItem.artist!
      }
      await store.receive(\.internalAction.requestArtwork)
      await store.receive(\.internalAction.applyArtwork, .init(systemSymbol: .photo)) {
        $0.artworkImage = .init(systemSymbol: .photo)
      }
    }
  }

  @Test(
    .dependencies {
      $0.mediaPlayer.getNowPlayingArtwork = { _ in .init(systemSymbol: .photo) }
    }
  )
  func testRequestArtwork() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    let nowPlayingItem = StubMediaItem()
    await store.send(.internalAction(.requestArtwork(nowPlayingItem)))
    await store.receive(\.internalAction.applyArtwork, .init(systemSymbol: .photo)) {
      $0.artworkImage = .init(systemSymbol: .photo)
    }
  }
}
