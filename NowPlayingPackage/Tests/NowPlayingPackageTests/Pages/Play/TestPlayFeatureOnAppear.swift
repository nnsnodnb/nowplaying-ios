//
//  TestPlayFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestPlayFeatureOnAppear {
  @Test
  func testMediaLibraryAuthorized() async throws {
    let nowPlayingItem = StubMediaItem(
      artworkImage: .init(systemSymbol: .photo),
    )

    await withDependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.mediaPlayer.requestAuthorization = {}
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

      await store.send(.onAppear) {
        $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
      }
      await store.receive(\.internalAction.authorizationSuccess) {
        $0.songName = "読み込み中..."
        $0.artistName = ""
      }
      await store.receive(\.internalAction.applyNowPlayingItem) {
        $0.songName = nowPlayingItem.title
        $0.artistName = nowPlayingItem.artist
        $0.album = nowPlayingItem.albumTitle
      }
      await store.receive(\.internalAction.requestArtwork)
      await store.receive(\.internalAction.applyArtwork, .init(systemSymbol: .photo)) {
        $0.artworkImage = .init(systemSymbol: .photo)
      }
    }
  }

  @Test(
    .dependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.mediaPlayer.requestAuthorization = { throw MediaPlayerClient.Error.denied }
    }
  )
  func testMediaLibraryDenied() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.onAppear) {
      $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    }
    await store.receive(\.internalAction.authorizationFailure, "ミュージックライブラリへのアクセスが拒否されました") {
      $0.alert = AlertState(
        title: {
          TextState("ミュージックライブラリへのアクセスが拒否されました")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("閉じる")
            },
          )
        },
      )
    }
  }

  @Test(
    .dependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.mediaPlayer.requestAuthorization = { throw MediaPlayerClient.Error.restricted }
    }
  )
  func testMediaLibraryRestricted() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.onAppear) {
      $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    }
    await store.receive(\.internalAction.authorizationFailure, "ミュージックライブラリへのアクセスが制限されています") {
      $0.alert = AlertState(
        title: {
          TextState("ミュージックライブラリへのアクセスが制限されています")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("閉じる")
            },
          )
        },
      )
    }
  }
}
