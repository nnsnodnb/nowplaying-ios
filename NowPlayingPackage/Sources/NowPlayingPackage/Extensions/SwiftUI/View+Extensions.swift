//
//  View+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import ComposableArchitecture
import DependenciesInterfaces
import SVProgressHUD
import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }

  func progress(_ enabled: Bool, status: String? = nil) -> some View {
    onChange(of: enabled, initial: false) { _, newValue in
      if newValue {
        if let status {
          SVProgressHUD.show(withStatus: status)
        } else {
          SVProgressHUD.show()
        }
      } else {
        SVProgressHUD.dismiss()
      }
    }
  }
}

extension View {
  func analyticsScreen(
    screenName: AnalyticsClient.ScreenName,
    extraParameters: [String: AnyHashableSendable] = [:],
  ) -> some View {
    analyticsScreen(screenName: screenName, parameters: extraParameters)
  }
}
