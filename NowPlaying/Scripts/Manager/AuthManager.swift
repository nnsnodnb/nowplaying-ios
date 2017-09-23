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

class AuthManager: NSObject {

    static let shared = AuthManager()

    fileprivate let keychain = KeychainSwift()

    func login(completion: (() -> ())?=nil) {
        Twitter.sharedInstance().logIn(completion: { [unowned self] (session, error) in
            guard session != nil else {
                return
            }
            self.keychain.set(session!.authToken, forKey: KeychainKey.authToken.rawValue)
            self.keychain.set(session!.authTokenSecret, forKey: KeychainKey.authTokenSecret.rawValue)
            self.keychain.synchronizable = true
            if let completion = completion {
                completion()
            }
        })
    }

    func logout(completion: () -> Void) {
        Twitter.sharedInstance().sessionStore.logOutUserID(Twitter.sharedInstance().sessionStore.session()!.userID)
        keychain.delete(KeychainKey.authToken.rawValue)
        keychain.delete(KeychainKey.authTokenSecret.rawValue)
        keychain.synchronizable = true
        completion()
    }
}
