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
            let callbackURL = URL(string: "swifter-\(Environments.twitterConsumerKey)://")!
            base?.authorize(withCallback: callbackURL, presentingFrom: presenting, success: { (accessToken, _) in
                if let token = accessToken {
                    observer(.success(token))
                } else {
                    fatalError()
                }
            }, failure: {
                observer(.error($0))
            })

            return Disposables.create()
        }
    }
}
