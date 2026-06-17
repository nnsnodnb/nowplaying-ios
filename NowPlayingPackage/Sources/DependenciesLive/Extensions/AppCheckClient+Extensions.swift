//
//  AppCheckClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import FirebaseAppCheck
import Foundation

public extension AppCheckClient {
  static let firebase: Self = .init(
    token: {
      let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
      return appCheckToken.token
    },
  )
}
