//
//  TestPostFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/22.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPostFeatureOnAppear {
  @Test(
    arguments: [AttachImageType.onlyArtwork, AttachImageType.screenShot],
  )
  func testIsWithAttachImage(attachImageType: AttachImageType) async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: false)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: true)
    }

    await withDependencies {
      $0.defaultAppStorage = .inMemory
    } operation: {
      @Shared(.appStorage(.blueskyWithImageType))
      var attachImageType = attachImageType

      let store = TestStore(
        initialState: PostFeature.State(
          blueskyAccounts: [blueskyAccountA, blueskyAccountB],
          title: "曲名",
          artist: "アーティスト名",
          album: "アルバム名",
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          isAttachImage: true,
          postFormat: "__songtitle__ by __artist__ on __album__ #NowPlaying",
        ),
        reducer: {
          PostFeature()
        },
      )

      await store.send(.onAppear) {
        $0.postableBlueskyAccount = blueskyAccountB
        $0.text = "曲名 by アーティスト名 on アルバム名 #NowPlaying"
        switch attachImageType {
        case .onlyArtwork:
          $0.attachmentImage = .init(systemSymbol: .photoFill)
        case .screenShot:
          $0.attachmentImage = .init(systemSymbol: .photo)
        }
      }
    }
  }

  func testIsNotWithAttachImage() async throws {
    let blueskyAccountA = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_a"))
      $0.set(\.isDefault, value: false)
    }
    let blueskyAccountB = try Stub.make(BlueskyAccount.self) {
      $0.set(\.id, value: .init("stub_id_b"))
      $0.set(\.isDefault, value: true)
    }

    let store = TestStore(
      initialState: PostFeature.State(
        blueskyAccounts: [blueskyAccountA, blueskyAccountB],
        title: "曲名",
        artist: "アーティスト名",
        album: "アルバム名",
        artwork: .init(systemSymbol: .photoFill),
        capturedImage: .init(systemSymbol: .photo),
        isAttachImage: false,
        postFormat: "__songtitle__ by __artist__ on __album__ #NowPlaying",
      ),
      reducer: {
        PostFeature()
      },
    )

    await store.send(.onAppear) {
      $0.postableBlueskyAccount = blueskyAccountB
      $0.text = "曲名 by アーティスト名 on アルバム名 #NowPlaying"
    }
  }
}
