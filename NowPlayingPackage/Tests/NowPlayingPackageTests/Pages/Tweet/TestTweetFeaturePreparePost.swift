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
  .dependency(\.date, .constant(.now)),
  .dependency(\.defaultAppStorage, .inMemory)
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
  func testIsOverUsablePostTicket() async throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 1)
    }
    let twitterAccount = try Stub.make(TwitterAccount.self)

    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [twitterAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        availablePostTicket: availablePostTicket,
        usePostTicketCount: 2,
        totalPostTicketCount: 1,
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
            TextState(.failedToRetrieveAuthenticationInformation)
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState(.close)
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
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 1)
    }
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia = try Stub.make(TwitterMedia.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
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
          availablePostTicket: availablePostTicket,
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
      if isEditing {
        await store.receive(\.internalAction.post)
      } else {
        await store.receive(\.internalAction.post) {
          $0.isEditing = true
        }
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
  func testExistAttachmentImage(isEditing: Bool) async throws {
    var availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 2)
    }
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia = try Stub.make(TwitterMedia.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
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
          availablePostTicket: availablePostTicket,
          totalPostTicketCount: 2,
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
        $0.isEditing = true
      }
      availablePostTicket.decreasePurchasedCount(amount: 1)
      await store.receive(\.internalAction.setAvailablePostTicket) {
        $0.availablePostTicket = availablePostTicket
        $0.totalPostTicketCount = 1
        $0.usePostTicketCount = 1
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
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 1)
    }
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = true

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
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
          availablePostTicket: availablePostTicket,
          totalPostTicketCount: 1,
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
      if isEditing {
        await store.receive(\.internalAction.post)
      } else {
        await store.receive(\.internalAction.post) {
          $0.isEditing = true
        }
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
}
