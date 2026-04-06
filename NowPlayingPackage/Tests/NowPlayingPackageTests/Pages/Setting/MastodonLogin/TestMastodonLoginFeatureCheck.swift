//
//  TestMastodonLoginFeatureCheck.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import StubKit
import Testing

@MainActor
struct TestMastodonLoginFeatureCheck {
  @Test
  func testIsCheckButtonDisabled() async throws {
    let store = TestStore(
      initialState: MastodonLoginFeature.State(
        isCheckButtonDisabled: true,
      ),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.check)
  }

  @Test
  func testSuccess() async throws {
    let mastodonInstance = try Stub.make(MastodonInstance.self) {
      $0.set(\.domain, value: "example.com")
    }

    await withDependencies {
      $0.mastodonAPI.getInstanceDetail = { _ in mastodonInstance }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          isCheckButtonDisabled: false,
          domain: "example.com",
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.check) {
        $0.isLoading = true
        $0.isFocused = false
      }
      await store.receive(\.internalAction.getMastodonInstanceSuccess) {
        $0.mastodonInstance = mastodonInstance
        $0.isLoading = false
      }
    }
  }

  @Test
  func testAlreadyMastodonInstance() async throws {
    let mastodonInstance = try Stub.make(MastodonInstance.self) {
      $0.set(\.domain, value: "example.com")
    }

    let store = TestStore(
      initialState: MastodonLoginFeature.State(
        isCheckButtonDisabled: false,
        domain: "example.com",
        mastodonInstance: mastodonInstance,
      ),
      reducer: {
        MastodonLoginFeature()
      },
    )

    await store.send(.check)
  }

  @Test(
    arguments: zip(
      [MastodonAPIClient.Error.invalidURL, MastodonAPIClient.Error.internalError],
      [LocalizedStringResource.isTheInstanceDomainIncorrect, LocalizedStringResource.anUnknownErrorHasOccurred],
    )
  )
  func testFailure(error: MastodonAPIClient.Error, localizedStringResource: LocalizedStringResource) async throws {
    await withDependencies {
      $0.mastodonAPI.getInstanceDetail = { _ in throw error }
    } operation: {
      let store = TestStore(
        initialState: MastodonLoginFeature.State(
          isCheckButtonDisabled: false,
          domain: "example.com",
        ),
        reducer: {
          MastodonLoginFeature()
        },
      )

      await store.send(.check) {
        $0.isLoading = true
        $0.isFocused = false
      }
      await store.receive(\.internalAction.getMastodonInstanceFailure, localizedStringResource) {
        $0.isFocused = true
        $0.isLoading = false
        $0.alert = AlertState(
          title: {
            TextState(localizedStringResource)
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
    }
  }
}
