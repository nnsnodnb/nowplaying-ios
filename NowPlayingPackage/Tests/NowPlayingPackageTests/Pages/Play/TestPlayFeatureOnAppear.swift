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
  @Test(
    arguments: [true, false]
  )
  func testMediaLibraryAuthorized(isPurchasedHideAds: Bool) async throws {
    let nowPlayingItem = StubMediaItem(
      artworkImage: .init(systemSymbol: .photo),
    )

    await withDependencies {
      $0.averageColor.make = { _ in UIColor.red }
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
        initialState: PlayFeature.State(
          isPurchasedHideAds: isPurchasedHideAds,
        ),
        reducer: {
          PlayFeature()
        },
      )

      if isPurchasedHideAds {
        await store.send(.onAppear)
      } else {
        await store.send(.onAppear) {
          $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
        }
      }
      await store.receive(\.internalAction.authorizationSuccess) {
        $0.songName = String(localized: .loading)
        $0.artistName = ""
      }
      await store.receive(\.internalAction.applyNowPlayingItem) {
        $0.songName = nowPlayingItem.title
        $0.artistName = nowPlayingItem.artist
        $0.album = nowPlayingItem.albumTitle
      }
      await store.receive(\.internalAction.requestArtwork)
      await store.receive(\.internalAction.applyArtwork) {
        $0.artworkImage = .init(systemSymbol: .photo)
        $0.backgroundColor = .red
      }
    }
  }

  @Test(
    arguments: [true, false]
  )
  func testMediaLibraryDenied(isPurchasedHideAds: Bool) async throws {
    await withDependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.mediaPlayer.requestAuthorization = { throw MediaPlayerClient.Error.denied }
    } operation: {
      let store = TestStore(
        initialState: PlayFeature.State(
          isPurchasedHideAds: isPurchasedHideAds,
        ),
        reducer: {
          PlayFeature()
        },
      )

      if isPurchasedHideAds {
        await store.send(.onAppear)
      } else {
        await store.send(.onAppear) {
          $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
        }
      }
      await store.receive(\.internalAction.authorizationFailure, String(localized: .accessToTheMusicLibraryWasDenied)) {
        $0.alert = AlertState(
          title: {
            TextState(.accessToTheMusicLibraryWasDenied)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.close)
              },
            )
          },
        )
      }
    }
  }

  @Test(
    arguments: [true, false]
  )
  func testMediaLibraryRestricted(isPurchasedHideAds: Bool) async throws {
    await withDependencies {
      $0.adUnit.playerBottomBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.mediaPlayer.requestAuthorization = { throw MediaPlayerClient.Error.restricted }
    } operation: {
      let store = TestStore(
        initialState: PlayFeature.State(
          isPurchasedHideAds: isPurchasedHideAds,
        ),
        reducer: {
          PlayFeature()
        },
      )

      if isPurchasedHideAds {
        await store.send(.onAppear)
      } else {
        await store.send(.onAppear) {
          $0.bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
        }
      }
      await store.receive(\.internalAction.authorizationFailure, String(localized: .accessToTheMusicLibraryIsRestricted)) {
        $0.alert = AlertState(
          title: {
            TextState(.accessToTheMusicLibraryIsRestricted)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.close)
              },
            )
          },
        )
      }
    }
  }
}
