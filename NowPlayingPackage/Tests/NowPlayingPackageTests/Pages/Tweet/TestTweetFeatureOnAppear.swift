//
//  TestTweetFeatureOnAppear.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/13.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestTweetFeatureOnAppear {
  @Test(
    arguments: [AttachImageType.onlyArtwork, AttachImageType.screenShot]
  )
  func testIsAttachImage(attachImageType: AttachImageType) async throws {
    try await withDependencies {
      $0.defaultAppStorage = .inMemory
    } operation: {
      @Shared(.appStorage(.twitterWithImageType))
      var attachImageType = attachImageType

      let twitterAccountA = try Stub.make(TwitterAccount.self) {
        $0.set(\.isDefault, value: false)
      }
      let twitterAccountB = try Stub.make(TwitterAccount.self) {
        $0.set(\.isDefault, value: true)
      }
      let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
        $0.set(\.remainingFreeCount, value: 2)
        $0.set(\.totalFreeCount, value: 3)
        $0.set(\.remainingPurchasedCount, value: 10)
        $0.set(\.totalPurchasedCount, value: 30)
      }

      await withDependencies {
        $0.secureKeyValueStore.getAvailablePostTicket = { availablePostTicket }
      } operation: {
        let store = TestStore(
          initialState: TweetFeature.State(
            twitterAccounts: [twitterAccountA, twitterAccountB],
            title: "曲名",
            artist: "アーティスト名",
            album: nil,
            artwork: .init(systemSymbol: .photoFill),
            capturedImage: .init(systemSymbol: .photo),
            isAttachImage: true,
            attachImageType: attachImageType,
            postFormat: "__songtitle__ / __artist__ (__album__) #NowPlaying",
          ),
          reducer: {
            TweetFeature()
          },
        )

        await store.send(.onAppear) {
          $0.postableTwitterAccount = twitterAccountB
          $0.text = "曲名 / アーティスト名 (不明なアルバム) #NowPlaying"
          switch attachImageType {
          case .onlyArtwork:
            $0.attachmentImage = .init(systemSymbol: .photoFill)
          case .screenShot:
            $0.attachmentImage = .init(systemSymbol: .photo)
          }
          $0.usePostTicketCount = 2
        }
        await store.receive(\.internalAction.setAvailablePostTicket, availablePostTicket) {
          $0.availablePostTicket = availablePostTicket
          $0.totalPostTicketCount = 12
        }
      }
    }
  }

  @Test
  func testIsNotAttachImage() async throws {
    let twitterAccountA = try Stub.make(TwitterAccount.self) {
      $0.set(\.isDefault, value: false)
    }
    let twitterAccountB = try Stub.make(TwitterAccount.self) {
      $0.set(\.isDefault, value: true)
    }
    let availablePostTicket = try Stub.make(AvailablePostTicket.self) {
      $0.set(\.remainingFreeCount, value: 2)
      $0.set(\.totalFreeCount, value: 3)
      $0.set(\.remainingPurchasedCount, value: 10)
      $0.set(\.totalPurchasedCount, value: 30)
    }

    await withDependencies {
      $0.secureKeyValueStore.getAvailablePostTicket = { availablePostTicket }
    } operation: {
      let store = TestStore(
        initialState: TweetFeature.State(
          twitterAccounts: [twitterAccountA, twitterAccountB],
          title: "曲名",
          artist: "アーティスト名",
          album: nil,
          artwork: .init(systemSymbol: .photoFill),
          capturedImage: .init(systemSymbol: .photo),
          isAttachImage: false,
          attachImageType: .onlyArtwork,
          postFormat: "__songtitle__ / __artist__ (__album__) #NowPlaying",
        ),
        reducer: {
          TweetFeature()
        },
      )

      await store.send(.onAppear) {
        $0.postableTwitterAccount = twitterAccountB
        $0.text = "曲名 / アーティスト名 (不明なアルバム) #NowPlaying"
        $0.usePostTicketCount = 1
      }
      await store.receive(\.internalAction.setAvailablePostTicket, availablePostTicket) {
        $0.availablePostTicket = availablePostTicket
        $0.totalPostTicketCount = 12
      }
    }
  }
}
