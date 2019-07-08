//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import FirebaseAuth
import FirebaseDatabase
import KeychainAccess
import RxSwift
import SafariServices
import SwifteriOS
import UIKit

enum AuthError: Swift.Error {
    case nullAccessToken
    case internalError
    case nullMe
}

struct LoginCallback {

    let userID: String
    let name: String
    let screenName: String
    let photoURL: URL
    let accessToken: String
    let accessTokenSecret: String
}

final class AuthManager: NSObject {

    private let disposeBag = DisposeBag()
    private let keychain = Keychain.nowPlaying
    private let authService: AuthService

    enum AuthService: Equatable {
        case twitter
        case mastodon(String)
    }

    init(authService: AuthService) {
        self.authService = authService
    }
}

// MARK: - Deprecated

extension AuthManager {

    @available(iOS, deprecated: 2.3.1)
    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
        keychain[.authToken] = nil
        keychain[.authTokenSecret] = nil
        completion()
    }

    @available(iOS, deprecated: 2.3.1)
    @discardableResult
    func mastodonLogout() -> Bool {
        do {
            try keychain.remove(.mastodonAccessToken)
            return true
        } catch {
            return false
        }
    }
}
