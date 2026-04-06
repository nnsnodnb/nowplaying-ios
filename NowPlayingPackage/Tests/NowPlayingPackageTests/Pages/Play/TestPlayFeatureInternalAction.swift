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
import StubKit
import Testing

@MainActor
struct TestPlayFeatureInternalAction {
  @Test
  func testAuthorizationSuccess() async throws {
    let nowPlayingItem = StubMediaItem()

    await withDependencies {
      $0.averageColor.make = { _ in UIColor.red }
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
          isPurchasedHideAds: false,
        ),
        reducer: {
          PlayFeature()
        },
      )

      await store.send(.internalAction(.authorizationSuccess)) {
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
    .dependencies {
      $0.averageColor.make = { _ in UIColor.red }
      $0.mediaPlayer.getNowPlayingArtwork = { _ in .init(systemSymbol: .photo) }
    }
  )
  func testRequestArtwork() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
      ),
      reducer: {
        PlayFeature()
      },
    )

    let nowPlayingItem = StubMediaItem()
    await store.send(.internalAction(.requestArtwork(nowPlayingItem)))
    await store.receive(\.internalAction.applyArtwork) {
      $0.artworkImage = .init(systemSymbol: .photo)
      $0.backgroundColor = .red
    }
  }

  @Test
  func testShowTweetSongNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: nil,
        artistName: "アーティスト名",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let twitterAccount = try Stub.make(TwitterAccount.self)

    await store.send(.internalAction(.showTweet([twitterAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowTweetSongNameIsLoading() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: String(localized: .loading),
        artistName: "",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let twitterAccount = try Stub.make(TwitterAccount.self)

    await store.send(.internalAction(.showTweet([twitterAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowTweetArtistNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: "曲名",
        artistName: nil,
      ),
      reducer: {
        PlayFeature()
      },
    )

    let twitterAccount = try Stub.make(TwitterAccount.self)

    await store.send(.internalAction(.showTweet([twitterAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowPostSongNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: nil,
        artistName: "アーティスト名",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await store.send(.internalAction(.showPost([blueskyAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowPostSongNameIsLoading() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: String(localized: .loading),
        artistName: "",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await store.send(.internalAction(.showPost([blueskyAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowPostArtistNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: "曲名",
        artistName: nil,
      ),
      reducer: {
        PlayFeature()
      },
    )

    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    await store.send(.internalAction(.showPost([blueskyAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowTootSongNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: nil,
        artistName: "アーティスト名",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await store.send(.internalAction(.showToot([mastodonAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowTootSongNameIsLoading() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: String(localized: .loading),
        artistName: "",
      ),
      reducer: {
        PlayFeature()
      },
    )

    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await store.send(.internalAction(.showToot([mastodonAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }

  @Test
  func testShowTootArtistNameIsNil() async throws {
    let store = TestStore(
      initialState: PlayFeature.State(
        isPurchasedHideAds: false,
        songName: "曲名",
        artistName: nil,
      ),
      reducer: {
        PlayFeature()
      },
    )

    let mastodonAccount = try Stub.make(MastodonAccount.self)

    await store.send(.internalAction(.showToot([mastodonAccount], .init(systemSymbol: .photo)))) {
      $0.alert = AlertState(
        title: {
          TextState(.failedToRetrieveTheInformationRequiredForPosting)
        },
        message: {
          TextState(.songTitleAndArtistNameCouldNotBeRetrieved)
        },
      )
    }
  }
}
