//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit
import KeychainAccess

class AuthManager: NSObject {

    static let shared = AuthManager()

    private let keychain = Keychain(service: keychainServiceKey)

    func login(completion: (() -> ())?=nil) {
        Twitter.sharedInstance().logIn(completion: { [unowned self] (session, error) in
            guard let session = session else {
                return
            }
            self.keychain[KeychainKey.authToken.rawValue] = session.authToken
            self.keychain[KeychainKey.authTokenSecret.rawValue] = session.authTokenSecret
            if let completion = completion {
                completion()
            }
        })
    }

    func logout(completion: () -> Void) {
        Twitter.sharedInstance().sessionStore.logOutUserID(Twitter.sharedInstance().sessionStore.session()!.userID)
        keychain[KeychainKey.authToken.rawValue] = nil
        keychain[KeychainKey.authTokenSecret.rawValue] = nil
        completion()
    }

    @discardableResult
    func mastodonLogout() -> Bool {
        do {
            try keychain.remove(KeychainKey.mastodonAccessToken.rawValue)
            return true
        } catch {
            return false
        }
    }
}
