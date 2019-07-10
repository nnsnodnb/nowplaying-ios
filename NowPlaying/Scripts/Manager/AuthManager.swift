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

    static func oldLogout() {
        AuthManager(authService: .twitter).logout {}  // Twitterログアウト (FirebaseAuth)
        try? Keychain.nowPlaying.remove(.authToken)
        try? Keychain.nowPlaying.remove(.authTokenSecret)
        AuthManager(authService: .mastodon("")).mastodonLogout()  // Mastodonログアウト
        UserDefaults.removeObject(forKey: .mastodonClientID)
        UserDefaults.removeObject(forKey: .mastodonClientSecret)
        UserDefaults.removeObject(forKey: .mastodonHostname)
        UserDefaults.removeObject(forKey: .isMastodonLogin)
    }

    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
        keychain[.authToken] = nil
        keychain[.authTokenSecret] = nil
        completion()
    }

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
