//
//  StubAuthenticator.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/16.
//

import DependenciesInterfaces
import Foundation
import OAuthenticator
import StubKit

struct StubAuthenticator: AuthenticatorProtocol {
  @discardableResult
  func authenticate(with userAuthenticator: Authenticator.UserAuthenticator?) async throws -> Login {
    try Stub.make(Login.self)
  }

  func response(for request: URLRequest) async throws -> (Data, URLResponse) {
    struct Error: Swift::Error {}

    throw Error()
  }
}
