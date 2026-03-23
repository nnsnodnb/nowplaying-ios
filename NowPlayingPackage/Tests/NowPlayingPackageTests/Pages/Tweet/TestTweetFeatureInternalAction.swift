//
//  TestTweetFeatureInternalAction.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/18.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.date, .constant(.now))
)
struct TestTweetFeatureInternalAction {
  @Test
  func testUploadImageDataSuccess() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia = try Stub.make(TwitterMedia.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.uploadMedia = { _, _ in twitterMedia }
      $0.twitterAPI.post = { _, _, _ in }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photoFill),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      guard let imageData = UIImage(systemSymbol: .photoFill).jpegData(compressionQuality: 0.3) else {
        Issue.record("imageData must be not nil.")
        return
      }
      await store.send(.internalAction(.uploadImageData(.init("stub_access_token"), imageData)))
      await store.receive(\.internalAction.post) {
        $0.temporaryMedia = twitterMedia
      }
      await store.receive(\.internalAction.posted) {
        $0.isLoading = false
        $0.showSuccess = true
      }
      await mainQueue.advance(by: .milliseconds(500))
      await store.receive(\.internalAction.dismiss) {
        $0.showSuccess = false
      }
      #expect(calledDismiss)
    }
  }

  @Test
  func testUploadImageDataFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
      $0.twitterAPI.uploadMedia = { _, _ in throw TwitterAPIClient.Error.internalError }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photoFill),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      guard let imageData = UIImage(systemSymbol: .photoFill).jpegData(compressionQuality: 0.3) else {
        Issue.record("imageData must be not nil.")
        return
      }
      await store.send(.internalAction(.uploadImageData(.init("stub_access_token"), imageData)))
      await store.receive(\.internalAction.postFailure) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("画像のアップロードに失敗しました")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      }
      await store.receive(\.internalAction.fetchTwitterAccounts)
      await store.receive(\.internalAction.refreshTwitterAccounts)
    }
  }

  @Test(arguments: [true, false])
  func testPostSuccess(hasMedia: Bool) async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia: TwitterMedia? = hasMedia ? try Stub.make(TwitterMedia.self) : nil
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.post = { _, _, _ in }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      if hasMedia {
        await store.send(.internalAction(.post(.init("stub_access_token"), twitterMedia))) {
          $0.temporaryMedia = twitterMedia
        }
      } else {
        await store.send(.internalAction(.post(.init("stub_access_token"), twitterMedia)))
      }
      await store.receive(\.internalAction.posted) {
        $0.isLoading = false
        $0.showSuccess = true
      }
      await mainQueue.advance(by: .milliseconds(500))
      await store.receive(\.internalAction.dismiss) {
        $0.showSuccess = false
      }
      #expect(calledDismiss)
    }
  }

  @Test
  func testPostFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
      $0.twitterAPI.post = { _, _, _ in throw TwitterAPIClient.Error.internalError }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.internalAction(.post(.init("stub_access_token"), nil)))
      await store.receive(\.internalAction.postFailure) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("ポストに失敗しました")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      }
      await store.receive(\.internalAction.fetchTwitterAccounts)
      await store.receive(\.internalAction.refreshTwitterAccounts)
      #expect(!calledDismiss)
    }
  }

  @Test
  func testPosted() async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.internalAction(.posted)) {
        $0.isLoading = false
        $0.showSuccess = true
      }
      await mainQueue.advance(by: .milliseconds(500))
      await store.receive(\.internalAction.dismiss) {
        $0.showSuccess = false
      }
      #expect(calledDismiss)
    }
  }

  @Test
  func test_PostFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.secureKeyValueStore.twitterAccounts = { [twitterAccount] }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          postableTwitterAccount: twitterAccount,
          text: "曲名 / アーティスト #NowPlaying",
          isLoading: true,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.internalAction(.postFailure("テスト"))) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("テスト")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      }
      await store.receive(\.internalAction.fetchTwitterAccounts)
      await store.receive(\.internalAction.refreshTwitterAccounts)
      #expect(!calledDismiss)
    }
  }
}
