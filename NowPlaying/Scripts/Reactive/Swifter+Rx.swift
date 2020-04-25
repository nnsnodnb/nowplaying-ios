//
//  Swifter+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SwifteriOS
import UIKit

extension Swifter: ReactiveCompatible {}

extension Reactive where Base: Swifter {

    func authorizeBrowser(presentingFrom presenting: UIViewController?) -> Single<Credential.OAuthAccessToken> {
        return .create { [weak base] (observer) -> Disposable in
            base?.authorize(withCallback: .twitterCallbackURL, presentingFrom: presenting, success: { (accessToken, _) in
                if let token = accessToken {
                    observer(.success(token))
                } else {
                    observer(.error(AuthError.unknown))
                }
            }, failure: {
                observer(.error($0))
            })

            return Disposables.create()
        }
    }
}

extension Reactive where Base: Swifter {

    struct TwitterUser {

        let userID: String
        let name: String
        let screenName: String
        let iconURLString: String
    }

    func showUser(tag: UserTag, includeEntities: Bool? = nil) -> Single<TwitterUser> {
        return .create { [weak base] (observer) -> Disposable in
            base?.showUser(tag, includeEntities: includeEntities, success: {
                guard let userID = $0["id_str"].string,
                    let name = $0["name"].string,
                    let screenName = $0["screen_name"].string,
                    let iconURLString = $0["profile_image_url_https"].string else {
                        observer(.error(APIError.valueError))
                        return
                }
                let object = TwitterUser(userID: userID, name: name, screenName: screenName, iconURLString: iconURLString)
                observer(.success(object))
            }, failure: {
                observer(.error($0))
            })

            return Disposables.create()
        }
    }
}
