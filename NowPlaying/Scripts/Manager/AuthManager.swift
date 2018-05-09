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
import FirebaseDatabase
import KeychainAccess

class AuthManager: NSObject {

    static let shared = AuthManager()

    private let keychain = Keychain(service: keychainServiceKey)

    func login(completion: (() -> ())?=nil) {
        Twitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            guard let wself = self, let session = session else {
                return
            }
            DispatchQueue.main.async {
                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                Auth.auth().signIn(with: credential) { (user, error) in
                    guard let user = user, error == nil else {
                        return
                    }
                    wself.keychain[KeychainKey.authToken.rawValue] = session.authToken
                    wself.keychain[KeychainKey.authTokenSecret.rawValue] = session.authTokenSecret

                    DispatchQueue.global().async {
                        let ref = Database.database().reference(withPath: "twitter")
                        ref.child(user.uid).setValue(["name": session.userName, "user_id": session.userID, "display_name": user.displayName])
                    }

                    if let completion = completion {
                        completion()
                    }
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
