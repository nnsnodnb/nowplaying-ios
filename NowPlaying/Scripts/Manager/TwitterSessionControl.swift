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

    func authorize(presenting: UIViewController) -> Observable<LoginCallback> {
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
                                .setValue(["display_name": name, "name": accessToken.screenName!, "user_id": accessToken.userID!])
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
}
