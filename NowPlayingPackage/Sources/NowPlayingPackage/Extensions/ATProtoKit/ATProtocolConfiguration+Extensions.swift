//
//  ATProtocolConfiguration+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import ATProtoKit
import Foundation

public extension ATProtocolConfiguration {
  // swiftlint:disable:next cyclomatic_complexity
  func authenticate(with handle: String, password: String) async throws { // swiftlint:disable:this function_body_length
    guard let pdsURL = URL(string: pdsURL) else {
      throw ATRequestPrepareError.emptyPDSURL
    }

    do {
      let response = try await ATProtoKit(
        apiClientConfiguration: .init(urlSessionConfiguration: configuration),
        pdsURL: self.pdsURL,
        canUseBlueskyRecords: false,
      ).createSession(
        with: handle,
        and: password,
        authenticationFactorToken: nil,
      )

      // Assemble the UserSession object and insert it to the keychain protocol.
      let convertedDIDDocument = self.convertDIDDocument(response.didDocument)

      var status: UserAccountStatus?

      switch response.status {
      case .suspended:
        status = .suspended
      case .takedown:
        status = .takedown
      case .deactivated:
        status = .deactivated
      default:
        status = nil
      }

      let userSession = UserSession(
        handle: response.handle,
        sessionDID: response.did,
        email: response.email,
        isEmailConfirmed: response.isEmailConfirmed,
        isEmailAuthenticationFactorEnabled: response.isEmailAuthenticatedFactor,
        didDocument: convertedDIDDocument,
        isActive: response.isActive,
        status: status,
        serviceEndpoint: try convertedDIDDocument?.checkServiceForATProto().serviceEndpoint ?? pdsURL,
        pdsURL: self.pdsURL
      )

      try await keychainProtocol.saveAccessToken(response.accessToken)
      try await keychainProtocol.saveRefreshToken(response.refreshToken)
      try await keychainProtocol.savePassword(password)

      await UserSessionRegistry.shared.register(instanceUUID, session: userSession)
    } catch let error as ATAPIError {
      switch error {
      case let .badRequest(error: responseError):
        if responseError.error == "AuthFactorTokenRequired" {
          let json = [
            "error": "AuthFactorTokenRequired",
            "message": "Two-factor authentication is enabled.",
          ]
          let data = try JSONSerialization.data(withJSONObject: json)
          let error = try JSONDecoder().decode(APIClientService.ATHTTPResponseError.self, from: data)
          throw ATAPIError.badRequest(error: error)
        } else {
          throw error
        }
      case let .unauthorized(error: responseError, wwwAuthenticate: _):
        // Handle 2FA requirement that comes as unauthorized instead of badRequest
        if responseError.error == "AuthFactorTokenRequired" {
          let json = [
            "error": "AuthFactorTokenRequired",
            "message": "Two-factor authentication is enabled.",
          ]
          let data = try JSONSerialization.data(withJSONObject: json)
          let error = try JSONDecoder().decode(APIClientService.ATHTTPResponseError.self, from: data)
          throw ATAPIError.badRequest(error: error)
        } else {
          throw error
        }
      default:
        throw error
      }
    } catch {
      throw error
    }
  }
}
