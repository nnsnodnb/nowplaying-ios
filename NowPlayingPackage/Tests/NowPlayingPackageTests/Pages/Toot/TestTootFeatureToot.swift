//
//  TestTootFeatureToot.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/07.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestTootFeatureToot {
  @Test
  func testIsDisabledTootButton() async throws {
    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        isDisableTootButton: true,
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.toot)
  }

  @Test
  func testTootableAccountIsNil() async throws {
    let store = TestStore(
      initialState: TootFeature.State(
        mastodonAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableMastodonAccount: nil,
        isDisableTootButton: false,
      ),
      reducer: {
        TootFeature()
      },
    )

    await store.send(.toot)
  }

  @Test
  func testTootSuccess() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)
    let mediaAttachment = try Stub.make(MastodonMediaAttachment.self)
    let mainQueue = DispatchQueue.test
    var calledDismiss = false

    await withDependencies {
      $0.mastodonAPI.uploadMedia = { _, _, _ in mediaAttachment }
      $0.mastodonAPI.toot = { _, _, _, _, _ in }
      $0.mastodonOAuth.getAccessToken = { _ in .init("stub_access_token") }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: TootFeature.State(
          mastodonAccounts: [mastodonAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: "アルバム名",
          artwork: nil,
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photo),
          postableMastodonAccount: mastodonAccount,
          isDisableTootButton: false,
        ),
        reducer: {
          TootFeature()
        },
      )

      await store.send(.toot) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.tooted) {
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
  func testTootFailed() async throws {
    let mastodonAccount = try Stub.make(MastodonAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.mastodonAPI.uploadMedia = { _, _, _ in throw MastodonAPIClient.Error.internalError }
      $0.mastodonOAuth.getAccessToken = { _ in .init("stub_access_token") }
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: TootFeature.State(
          mastodonAccounts: [mastodonAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: "アルバム名",
          artwork: nil,
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photo),
          postableMastodonAccount: mastodonAccount,
          isDisableTootButton: false,
        ),
        reducer: {
          TootFeature()
        },
      )

      await store.send(.toot) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.tootFailure, String(localized: .failedToToot)) {
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState(.failedToToot)
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
      #expect(!calledDismiss)
    }
  }
}
