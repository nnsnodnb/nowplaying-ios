//
//  TestLicenseListFeaturePushLicenseDetail.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/04.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
struct TestLicenseListFeaturePushLicenseDetail {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: LicenseListFeature.State(),
      reducer: {
        LicenseListFeature()
      },
    )

    await store.send(.pushLicenseDetail(LicensesPlugin.licenses[0]))
    await store.receive(\.delegate.pushLicenseDetail)
  }
}
