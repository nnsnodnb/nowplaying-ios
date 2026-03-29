//
//  AppInfo.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/29.
//

import Foundation

public struct AppInfo: Decodable, Sendable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case appVersion = "app_version"
  }

  // MARK: - Properties
  public let appVersion: AppVersion
}

// MARK: - AppVersion
public extension AppInfo {
  struct AppVersion: Decodable, Sendable {
    // MARK: - Properties
    public let require: String
    public let latest: String
  }
}
