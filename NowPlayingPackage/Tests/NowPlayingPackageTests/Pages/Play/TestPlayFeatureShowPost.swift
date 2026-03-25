//
//  TestPlayFeatureShowPost.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestPlayFeatureShowPost {
  @Test
  func testTwitter() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.imageRenderer.image = { .init(systemSymbol: .photo) }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: PlayFeature.State(
          isPurchasedHideAds: false,
          artworkImage: .init(systemSymbol: .photoFill),
          songName: "曲名",
          artistName: "アーティスト名",
        ),
        reducer: {
          PlayFeature()
        },
      )

      await store.send(.showPost(.twitter))
      await store.receive(\.internalAction.captureScreen)
      await mainQueue.advance(by: .milliseconds(300))
      await store.receive(\.internalAction.showTweet) {
        $0.tweet = .init(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
        )
      }
    }
  }

  @Test(
    .dependencies {
      $0.secureKeyValueStore.getTwitterAccounts = { [] }
    }
  )
  func testTwitterAccountIsEmpty() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        artworkImage: .init(systemSymbol: .photoFill),
        songName: "曲名",
        artistName: "アーティスト名",
      ),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.showPost(.twitter))
    await store.receive(\.internalAction.emptySNSAccounts) {
      $0.alert = AlertState(
        title: {
          TextState("Xアカウントが設定されていません")
        },
        message: {
          TextState("左下の設定ボタンから「X設定」→「アカウント管理」→左上のボタンから認証を行ってください")
        },
      )
    }
  }

  @Test
  func testBluesky() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    let mainQueue = DispatchQueue.test

    await withDependencies {
      $0.imageRenderer.image = { .init(systemSymbol: .photo) }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.getBlueskyAccounts = { [blueskyAccount] }
    } operation: {
      let store = TestStore(
        initialState: PlayFeature.State(
          isPurchasedHideAds: false,
          artworkImage: .init(systemSymbol: .photoFill),
          songName: "曲名",
          artistName: "アーティスト名",
        ),
        reducer: {
          PlayFeature()
        },
      )

      await store.send(.showPost(.bluesky))
      await store.receive(\.internalAction.captureScreen)
      await mainQueue.advance(by: .milliseconds(300))
      await store.receive(\.internalAction.showPost) {
        $0.post = .init(
          blueskyAccounts: [blueskyAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
        )
      }
    }
  }

  @Test(
    .dependencies {
      $0.secureKeyValueStore.getBlueskyAccounts = { [] }
    }
  )
  func testBlueskyAccountIsEmpty() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        artworkImage: .init(systemSymbol: .photoFill),
        songName: "曲名",
        artistName: "アーティスト名",
      ),
      reducer: {
        PlayFeature()
      },
    )

    await store.send(.showPost(.bluesky))
    await store.receive(\.internalAction.emptySNSAccounts) {
      $0.alert = AlertState(
        title: {
          TextState("Blueskyアカウントが設定されていません")
        },
        message: {
          TextState("左下の設定ボタンから「Bluesky設定」→「アカウント管理」→左上のボタンから認証を行ってください")
        },
      )
    }
  }
}
