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
            self.keychain.set(session!.authToken, forKey: "authToken")
            self.keychain.set(session!.authTokenSecret, forKey: "authTokenSecret")
            self.keychain.synchronizable = true
            if let completion = completion {
                completion()
            }
        })
    }
}
