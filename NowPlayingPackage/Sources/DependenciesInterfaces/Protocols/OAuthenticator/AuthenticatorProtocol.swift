//
//  AuthenticatorProtocol.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/15.
//

import Foundation
import OAuthenticator

public protocol AuthenticatorProtocol {
  @discardableResult
  func authenticate(with userAuthenticator: Authenticator.UserAuthenticator?) async throws -> Login
  func response(for request: URLRequest) async throws -> (Data, URLResponse)
}

public extension AuthenticatorProtocol {
  @discardableResult
  func authenticate() async throws -> Login {
    try await authenticate(with: nil)
  }
}
