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
  .dependency(\.date, .constant(.now)),
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTweetFeatureInternalAction {
  @Test
  func testSetAvailablePostTicketOverUsablePostTicket() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        attachmentImage: .init(systemSymbol: .photo),
        usePostTicketCount: 2
      ),
      reducer: {
        TweetFeature()
      },
    )

    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 0)
      $0.set(\.remainingPurchasedCount, value: 1)
    }

    await store.send(.internalAction(.setAvailablePostTicket(availablePostTicket))) {
      $0.availablePostTicket = availablePostTicket
      $0.totalPostTicketCount = 1
      $0.overUsablePostTicket = true
    }
  }

  @Test
  func testSetAvailablePostTicketNotOverUsablePostTicket() async throws {
    let store = TestStore(
      initialState: TweetFeature.State(
        twitterAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        attachmentImage: .init(systemSymbol: .photo),
        usePostTicketCount: 2
      ),
      reducer: {
        TweetFeature()
      },
    )

    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 1)
      $0.set(\.remainingPurchasedCount, value: 1)
    }

    await store.send(.internalAction(.setAvailablePostTicket(availablePostTicket))) {
      $0.availablePostTicket = availablePostTicket
      $0.totalPostTicketCount = 2
    }
  }

  @Test
  func testUploadImageDataSuccessUseFreePostTicket() async throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 2)
      $0.set(\.remainingPurchasedCount, value: 0)
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
        $0.isEditing = true
      }
      var availablePostTicket = availablePostTicket
      availablePostTicket.decreaseFreeCount(amount: 1)
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

  @Test
  func testUploadImageDataSuccessUseFreeAndPurchasePostTicket() async throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 1)
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
          availablePostTicket: availablePostTicket,
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
        $0.isEditing = true
      }
      var availablePostTicket = availablePostTicket
      availablePostTicket.decreaseFreeCount(amount: 1)
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

  @Test
  func testUploadImageDataSuccessUsePurchasePostTicket() async throws {
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
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
        $0.isEditing = true
      }
      var availablePostTicket = availablePostTicket
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

  @Test
  func testUploadImageDataFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)

    await withDependencies {
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
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
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingPurchasedCount, value: 1)
    }
    let mainQueue = DispatchQueue.test
    let twitterAccount = try Stub.make(TwitterAccount.self)
    let twitterMedia: TwitterMedia? = hasMedia ? try Stub.make(TwitterMedia.self) : nil
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.secureKeyValueStore.setAvailablePostTicket = { _ in }
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
          availablePostTicket: availablePostTicket,
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
          $0.isEditing = true
        }
      } else {
        await store.send(.internalAction(.post(.init("stub_access_token"), twitterMedia))) {
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

  @Test
  func testPostFailure() async throws {
    let twitterAccount = try Stub.make(TwitterAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
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

      await store.send(.internalAction(.post(.init("stub_access_token"), nil))) {
        $0.isEditing = true
      }
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
      $0.secureKeyValueStore.getTwitterAccounts = { [twitterAccount] }
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
