//
//  TestPostFeaturePost.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestPostFeaturePost {
  @Test
  func testIsDisabledPostButton() async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        isDisablePostButton: true,
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.post)
  }

  @Test
  func testPostableAccountIsNil() async throws {
    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: nil,
        capturedImage: .init(systemSymbol: .photo),
        postableBlueskyAccount: nil,
        isDisablePostButton: false,
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.post)
  }

  @Test
  func testPostSuccess() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    let mainQueue = DispatchQueue.test
    var calledDismiss = false

    await withDependencies {
      $0.blueskyAPI.createPostRecord = { _, _, _ in }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: PostFeature.State(
          blueskyAccounts: [blueskyAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: "アルバム名",
          artwork: nil,
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photo),
          postableBlueskyAccount: blueskyAccount,
          isDisablePostButton: false,
        ),
        reducer: {
          PostFeature()
        },
      )

      await store.send(.post) {
        $0.isLoading = true
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
  func testPostFailed() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.blueskyAPI.createPostRecord = { _, _, _ in throw BlueskyAPIClient.Error.unknown }
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: PostFeature.State(
          blueskyAccounts: [blueskyAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: "アルバム名",
          artwork: nil,
          capturedImage: .init(systemSymbol: .photo),
          attachmentImage: .init(systemSymbol: .photo),
          postableBlueskyAccount: blueskyAccount,
          isDisablePostButton: false,
        ),
        reducer: {
          PostFeature()
        },
      )

      await store.send(.post) {
        $0.isLoading = true
      }
      await store.receive(\.internalAction.postFailure, "ポストに失敗しました") {
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
      #expect(!calledDismiss)
    }
  }
}
