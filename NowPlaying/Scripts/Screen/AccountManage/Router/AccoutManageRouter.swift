//
//  AccoutManageRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import SwifteriOS
import UIKit

protocol AccountManageViewer: UIViewController {}

struct AuthAccessToken {

    let key: String
    let secret: String
    let userID: String
}

protocol AccountManageRouter: AnyObject {

    init(view: AccountManageViewer)
    func login() -> Observable<AuthAccessToken>
}

final class TwitterAccountManageRouterImpl: AccountManageRouter {

    private(set) weak var view: AccountManageViewer!

    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)

    init(view: AccountManageViewer) {
        self.view = view
    }

    func login() -> Observable<AuthAccessToken> {
        return .create { [weak self] (observer) -> Disposable in
            self?.swifter.authorize(withCallback: .twitterCallbackURL, presentingFrom: self?.view, success: { (token, _) in
                guard let token = token, let userID = token.userID else {
                    observer.onError(AuthError.unknown)
                    return
                }
                observer.onNext(.init(key: token.key, secret: token.secret, userID: userID))
                observer.onCompleted()
            }, failure: {
                observer.onError($0)
            })
            return Disposables.create()
        }
    }
}

final class AccountManageRouterImpl: AccountManageRouter {

    private(set) weak var view: AccountManageViewer!

    init(view: AccountManageViewer) {
        self.view = view
    }

    func login() -> Observable<AuthAccessToken> {
        fatalError("Not implementation")
    }
}
