//
//  AnalyticsScreenModifier.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

private struct AnalyticsScreenModifier: ViewModifier {
  let screenName: AnalyticsClient.ScreenName
  let parameters: [String: AnyHashableSendable]

  func body(content: Content) -> some View {
    content
      .task { @MainActor in
        @Dependency(\.analytics)
        var analytics

        await analytics.analyticsScreen(screenName, parameters)
      }
  }
}

public extension View {
  func analyticsScreen(
    screenName: AnalyticsClient.ScreenName,
    parameters: [String: AnyHashableSendable],
  ) -> some View {
    modifier(
      AnalyticsScreenModifier(
        screenName: screenName,
        parameters: parameters,
      )
    )
  }
}
