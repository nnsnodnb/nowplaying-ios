//
//  TestTweetFeaturePreparePost.swift
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
@Suite(
  .dependency(\.date, .constant(.now))
)
struct TestTweetFeaturePreparePost {
  @Test
  func testIsDisablePostButton() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        text: "",
        isDisablePostButton: true,
      ),
      reducer: {
        TweetFeature()
      },
    )

    await store.send(.preparePost)
  }

  @Test
  func testGetAccessTokenFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
      $0.twitterOAuth.getAccessToken = { _ in throw TwitterOAuthClient.Error.internalError }
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
          text: "曲名 / アーティスト名 #NowPlaying",
          isDisablePostButton: false,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.preparePost) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.postFailure) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState("認証情報の取得に失敗しました")
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

  @Test(arguments: [true, false])
  func testExistTemporaryMedia(isEditing: Bool) async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia = try Stub.make(TwitterMedia.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.post = { _, _, _ in }
      $0.twitterOAuth.getAccessToken = { _ in .init("stub_access_token") }
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
          text: "曲名 / アーティスト名 #NowPlaying",
          temporaryMedia: twitterMedia,
          isEditing: isEditing,
          isDisablePostButton: false,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.preparePost) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.post)
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

  @Test(arguments: [true, false])
  func testExistAttachmentImage(isEditing: Bool) async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia = try Stub.make(TwitterMedia.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.uploadMedia = { _, _ in twitterMedia }
      $0.twitterAPI.post = { _, _, _ in }
      $0.twitterOAuth.getAccessToken = { _ in .init("stub_access_token") }
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
          text: "曲名 / アーティスト名 #NowPlaying",
          isEditing: isEditing,
          isDisablePostButton: false,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.preparePost) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.uploadImageData)
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

  @Test(arguments: [true, false])
  func testOnlyText(isEditing: Bool) async throws {
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = true

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.twitterAPI.post = { _, _, _ in }
      $0.twitterOAuth.getAccessToken = { _ in .init("stub_access_token") }
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
          text: "曲名 / アーティスト名 #NowPlaying",
          isEditing: isEditing,
          isDisablePostButton: false,
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.preparePost) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.post)
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
}
