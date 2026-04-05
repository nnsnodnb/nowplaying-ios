//
//  Client+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import Foundation
import MastodonKit

public extension Client {
  func response<Model: Sendable>(for request: MastodonKit.Request<Model>) async throws -> Model {
    try await withUnsafeThrowingContinuation { continuation in
      run(request) { result in
        switch result {
        case let .success(model, _):
          continuation.resume(returning: model)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
