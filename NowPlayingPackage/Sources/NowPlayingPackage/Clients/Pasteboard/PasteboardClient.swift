//
//  PasteboardClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/08.
//

import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct PasteboardClient: Sendable {
  public var setString: @Sendable (String) -> Void = { _ in }
}

// MARK: - DependencyKey
extension PasteboardClient: DependencyKey {
  public static let liveValue: Self = .init(
    setString: { string in
      UIPasteboard.general.string = string
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var pasteboard: PasteboardClient {
    get {
      self[PasteboardClient.self]
    }
    set {
      self[PasteboardClient.self] = newValue
    }
  }
}
