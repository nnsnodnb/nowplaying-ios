//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit
import KeychainSwift
import FirebaseAuth

class AuthManager: NSObject {

    static let shared = AuthManager()

    fileprivate let keychain = KeychainSwift()

    func login(completion: (() -> Void)?, failed: ((Error) -> Void)?) {
        Twitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            guard let wself = self, let session = session else {
                failed?(error!)
                return
            }
            wself.keychain.set(session.authToken, forKey: KeychainKey.authToken.rawValue)
            wself.keychain.set(session.authTokenSecret, forKey: KeychainKey.authTokenSecret.rawValue)
            wself.keychain.synchronizable = true
            let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                guard error == nil else {
                    failed?(error!)
                    return
                }
                completion?()
            })
        })
    }

    func logout(completion: () -> Void, failed: ((Error) -> Void)?) {
        Twitter.sharedInstance().sessionStore.logOutUserID(Twitter.sharedInstance().sessionStore.session()!.userID)
        keychain.delete(KeychainKey.authToken.rawValue)
        keychain.delete(KeychainKey.authTokenSecret.rawValue)
        keychain.synchronizable = true
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError {
            failed?(signOutError)
        }
        completion()
    }

    @discardableResult
    func mastodonLogout() -> Bool {
        return keychain.delete(KeychainKey.mastodonAccessToken.rawValue)
    }
}
