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

final class AuthManager: NSObject {

    static let shared = AuthManager()

    private let keychain = Keychain(service: keychainServiceKey)

    func login(completion: @escaping (Error?) -> Void) {
        TWTRTwitter.sharedInstance().logIn { [weak self] (session, error) in
            DispatchQueue.global().async {
                guard let wself = self, let session = session else {
                    completion(error)
                    return
                }
                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                Auth.auth().signIn(with: credential) { (result, error) in
                    guard let user = result?.user, error == nil else {
                        completion(error)
                        return
                    }
                    wself.keychain[KeychainKey.authToken.rawValue] = session.authToken
                    wself.keychain[KeychainKey.authTokenSecret.rawValue] = session.authTokenSecret

                    DispatchQueue.global(qos: .utility).async {
                        let ref = Database.database().reference(withPath: "twitter")
                        ref.child(user.uid).setValue(["name": session.userName, "user_id": session.userID,
                                                      "display_name": user.displayName])
                    }

                    completion(nil)
                }
            }
        }
    }

    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
        TWTRTwitter.sharedInstance().sessionStore.logOutUserID(TWTRTwitter.sharedInstance().sessionStore.session()!.userID)
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
