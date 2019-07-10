//
//  TwitterSessionControl.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import RxCocoa
import RxSwift
import SafariServices
import SwifteriOS
import UIKit

struct TwitterSessionControl {

    func tryAuthorizeSSO() -> Observable<Credential.OAuthAccessToken> {
        return .create { (observer) -> Disposable in
            let swifter = Swifter(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret)
            swifter.authorizeSSO(success: {
                observer.onNext($0)
                observer.onCompleted()
            }, failure: { (error) in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func tryAuthorizeBrowser(presenting: UIViewController) -> Observable<Credential.OAuthAccessToken> {
        return .create { (observer) -> Disposable in
            let swifter = Swifter(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret)
            let callbackURL = URL(string: "nowplaying-ios-nnsnodnb://twitter/oauth/success")!
            swifter.authorize(
                withCallback: callbackURL, presentingFrom: presenting, safariDelegate: presenting as? SFSafariViewControllerDelegate,
                success: { (accessToken, _) in
                    guard let accessToken = accessToken else {
                        observer.onError(AuthError.nullAccessToken)
                        return
                    }
                    observer.onNext(accessToken)
                    observer.onCompleted()
            }, failure: {
                observer.onError($0)
            })
            return Disposables.create()
        }
    }

    static func handleSuccessLogin(_ accessToken: Credential.OAuthAccessToken) -> Observable<LoginCallback> {
        return .create { (observer) -> Disposable in
            // Firebase Auth
            let credential = TwitterAuthProvider.credential(withToken: accessToken.key, secret: accessToken.secret)
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                guard let authDataResult = authDataResult, error == nil else {
                    observer.onError(error!)
                    return
                }
                let userID = accessToken.userID ?? authDataResult.additionalUserInfo?.profile?["id_str"] as? String ?? ""
                let screenName = accessToken.screenName ?? authDataResult.additionalUserInfo?.profile?["screen_name"] as? String ?? ""
                let name: String = authDataResult.additionalUserInfo?.profile?["name"] as? String ?? authDataResult.user.displayName ?? ""
                DispatchQueue.global(qos: .utility).async {
                    Database.database().reference(withPath: "twitter").child(authDataResult.user.uid)
                        .setValue(["display_name": name, "name": screenName, "user_id": userID])
                }
                let profileImageURLHttps = authDataResult.additionalUserInfo?.profile?["profile_image_url_https"] as? String ?? ""
                let photoURL = URL(string: profileImageURLHttps.replacingOccurrences(of: "_normal", with: ""))!

                let callback = LoginCallback(userID: userID, name: name, screenName: screenName,
                                             photoURL: photoURL, accessToken: accessToken.key, accessTokenSecret: accessToken.secret)
                observer.onNext(callback)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
