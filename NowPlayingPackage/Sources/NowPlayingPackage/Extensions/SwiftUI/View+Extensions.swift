//
//  View+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import FirebaseAnalytics
import KRProgressHUD
import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }

  func progress(_ enabled: Bool) -> some View {
    onChange(of: enabled, initial: false) { _, newValue in
      if newValue {
        KRProgressHUD.show()
      } else {
        KRProgressHUD.dismiss()
      }
    }
  }
}

extension View {
  func analyticsScreen(
    screenName: AnalyticsClient.ScreenName,
    extraParameters: [String: Any] = [:],
  ) -> some View {
    analyticsScreen(name: screenName.rawValue, extraParameters: extraParameters)
  }
}
