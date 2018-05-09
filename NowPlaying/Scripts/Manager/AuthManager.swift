//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit
import FirebaseAuth
import KeychainAccess

class AuthManager: NSObject {

    static let shared = AuthManager()

    private let keychain = Keychain(service: keychainServiceKey)

    func login(completion: (() -> ())?=nil) {
        Twitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            guard let wself = self, let session = session else {
                return
            }
            let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
            Auth.auth().signIn(with: credential) { (user, error) in
                if user == nil && error != nil {
                    return
                }
                wself.keychain[KeychainKey.authToken.rawValue] = session.authToken
                wself.keychain[KeychainKey.authTokenSecret.rawValue] = session.authTokenSecret
                if let completion = completion {
                    completion()
                }
            }
        })
    }

    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
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
