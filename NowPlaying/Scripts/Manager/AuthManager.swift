//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import KeychainAccess
import RxSwift
import SafariServices
import SwifteriOS
import UIKit

final class AuthManager: NSObject {

    static let shared = AuthManager()

    private let keychain = Keychain.nowPlaying

    enum AuthError: Swift.Error {
        case nullAccessToken
    }

    struct LoginCallback {

        let userID: String
        let name: String
        let screenName: String
        let photoURL: URL
        let accessToken: String
        let accessTokenSecret: String
    }

    func login(presenting: UIViewController) -> Observable<LoginCallback> {
        return .create { (observer) -> Disposable in
            let callbackURL = URL(string: "nowplaying-ios-nnsnodnb://twitter/oauth/success")!
            let swifter = Swifter(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret)
            swifter.authorize(
                withCallback: callbackURL, presentingFrom: presenting, safariDelegate: presenting as? SFSafariViewControllerDelegate,
                success: { (accessToken, _) in
                    guard let accessToken = accessToken else {
                        observer.onError(AuthError.nullAccessToken)
                        return
                    }
                    // Firebase Auth
                    let credential = TwitterAuthProvider.credential(withToken: accessToken.key, secret: accessToken.secret)
                    Auth.auth().signIn(with: credential) { (authDataResult, error) in
                        guard let authDataResult = authDataResult, error == nil else {
                            observer.onError(error!)
                            return
                        }
                        let name: String = authDataResult.additionalUserInfo?.profile?["name"] as? String ?? authDataResult.user.displayName ?? ""
                        DispatchQueue.global(qos: .utility).async {
                            Database.database().reference(withPath: "twitter").child(authDataResult.user.uid)
                                .setValue(
                                    [
                                        "display_name": name,
                                        "name": accessToken.screenName!,
                                        "user_id": accessToken.userID!
                                    ]
                                )
                        }
                        let profileImageURLHttps = authDataResult.additionalUserInfo?.profile?["profile_image_url_https"] as? String ?? ""
                        let photoURL = URL(string: profileImageURLHttps.replacingOccurrences(of: "_normal", with: ""))!

                        let callback = LoginCallback(userID: accessToken.userID!, name: name, screenName: accessToken.screenName!,
                                                     photoURL: photoURL, accessToken: accessToken.key, accessTokenSecret: accessToken.secret)
                        observer.onNext(callback)
                        observer.onCompleted()
                    }
            }, failure: {
                observer.onError($0)
            })
            return Disposables.create()
        }
    }

    func login(completion: @escaping (Error?) -> Void) {
        // FIXME: ログイン実装
//        TWTRTwitter.sharedInstance().logIn { [weak self] (session, error) in
//            DispatchQueue.global().async {
//                guard let wself = self, let session = session else {
//                    completion(error)
//                    return
//                }
//                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
//                Auth.auth().signIn(with: credential) { (result, error) in
//                    guard let user = result?.user, error == nil else {
//                        completion(error)
//                        return
//                    }
//                    wself.keychain[.authToken] = session.authToken
//                    wself.keychain[.authTokenSecret] = session.authTokenSecret
//
//                    DispatchQueue.global(qos: .utility).async {
//                        let ref = Database.database().reference(withPath: "twitter")
//                        ref.child(user.uid).setValue(["name": session.userName, "user_id": session.userID,
//                                                      "display_name": user.displayName])
//                    }
//
//                    completion(nil)
//                }
//            }
//        }
    }

    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
        // FIXME: Twitterログアウト実装
//        TWTRTwitter.sharedInstance().sessionStore.logOutUserID(TWTRTwitter.sharedInstance().sessionStore.session()!.userID)
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
