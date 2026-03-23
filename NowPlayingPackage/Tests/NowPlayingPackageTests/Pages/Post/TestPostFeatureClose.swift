//
//  TestPostFeatureClose.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestPostFeatureClose {
  @Test
  func testIsEditing() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)

    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [blueskyAccount],
        title: "曲名",
        artist: "アーティスト名",
        album: nil,
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        isEditing: true,
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.close) {
      $0.alert = AlertState(
        title: {
          TextState("ポストを削除します")
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState("キャンセル")
            },
          )
          ButtonState(
            role: .destructive,
            action: .delete,
            label: {
              TextState("削除")
            },
          )
        },
      )
    }
  }

  @Test
  func testIsNotEditing() async throws {
    let blueskyAccount = try Stub.make(BlueskyAccount.self)
    var calledDismiss = false

    await withDependencies {
      $0.dismiss = DismissEffect { calledDismiss = true }
    } operation: {
      let store = TestStore(
        initialState: PostFeature.State(
          blueskyAccounts: [blueskyAccount],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          isEditing: false,
        ),
        reducer: {
          PostFeature()
        },
      )

      await store.send(.close)
      #expect(calledDismiss)
    }
  }
}
