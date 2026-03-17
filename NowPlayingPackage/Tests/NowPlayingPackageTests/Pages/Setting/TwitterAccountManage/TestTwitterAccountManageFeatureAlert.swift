//
//  TestTwitterAccountManageFeatureAlert.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/10.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestTwitterAccountManageFeatureAlert {
  @Test
  func testAlertPresentedOpenRewardedAd() async throws {
    let oauthURL = URL(string: "https://testserver/oauth")!
    let codeVerifier = TwitterOAuthClient.CodeVerifier("stub_code_verifier")

    await withDependencies {
      $0.adUnit.addTwitterAccountRewardAdUnitID = { "ca-app-pub-3940256099942544/1712485313" }
      $0.rewardedAd.load = { _ in }
      $0.rewardedAd.show = { _ in 1 }
      $0.twitterOAuth.getAuthenticateURL = { (oauthURL, codeVerifier) }
    } operation: {
      let store = TestStore(
        initialState: TwitterAccountManageFeature.State(
          alert: AlertState(
            title: {
              TextState("テスト")
            },
            actions: {
              ButtonState(
                action: .openRewardedAd,
                label: {
                  TextState("視聴する")
                },
              )
            },
          ),
        ),
        reducer: {
          TwitterAccountManageFeature()
        },
      )

      await store.send(.alert(.presented(.openRewardedAd))) {
        $0.alert = nil
      }
      await store.receive(\.oauth) {
        $0.oauthURL = oauthURL
        $0.codeVerifier = codeVerifier
      }
      await store.receive(\.preloadRewardedAds)
    }
  }

  @Test
  func testAlertDismiss() async throws {
    let store = TestStore(
      initialState: TwitterAccountManageFeature.State(
        alert: AlertState(
          title: {
            TextState("テスト")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      ),
      reducer: {
        TwitterAccountManageFeature()
      },
    )

    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
