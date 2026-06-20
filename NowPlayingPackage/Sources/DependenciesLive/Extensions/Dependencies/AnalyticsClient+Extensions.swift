//
//  AnalyticsClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import FirebaseAnalytics
import Foundation
import SwiftUI

public extension AnalyticsClient {
  static let firebase: Self = .init(
    logEvent: { event in
      Analytics.logEvent(
        event.eventName,
        parameters: event.parameters,
      )
    },
    analyticsScreen: { screenName, parameters in
      var parameters = parameters
      parameters[AnalyticsParameterScreenName] = screenName.rawValue
      parameters[AnalyticsParameterScreenClass] = "Class"
      Analytics.logEvent(
        AnalyticsEventScreenView,
        parameters: parameters,
      )
    },
    setUserProperty: { userProperty in
      Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
    },
  )
}
