//
//  AuthClient+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/06/17.
//

import DependenciesInterfaces
import FirebaseAuth
import Foundation

public extension AuthClient {
  // MARK: - Error
  enum Error: Swift.Error {
    case internalError
  }

  static let firebase: Self = .init(
    isSignedIn: {
      Auth.auth().currentUser != nil
    },
    currentUserID: {
      Auth.auth().currentUser?.uid
    },
    isAnonymous: {
      Auth.auth().currentUser?.isAnonymous == true
    },
    signInAnonymously: {
      _ = try await Auth.auth().signInAnonymously()
    },
    signOut: {
      try Auth.auth().signOut()
    },
    getIDToken: {
      guard let currentUser = Auth.auth().currentUser else {
        throw Error.internalError
      }
      return try await currentUser.getIDToken()
    },
  )
}
