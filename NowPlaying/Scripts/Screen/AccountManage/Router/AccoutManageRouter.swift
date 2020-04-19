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

protocol AccountManageRouter: AnyObject {

    init(view: AccountManageViewer)
    func login() -> Single<Credential.OAuthAccessToken>
}

final class TwitterAccountManageRouterImpl: AccountManageRouter {

    private(set) weak var view: AccountManageViewer!

    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)

    init(view: AccountManageViewer) {
        self.view = view
    }

    func login() -> Single<Credential.OAuthAccessToken> {
        return swifter.rx.authorizeBrowser(presentingFrom: view)
    }
}

final class AccountManageRouterImpl: AccountManageRouter {

    private(set) weak var view: AccountManageViewer!

    init(view: AccountManageViewer) {
        self.view = view
    }

    func login() -> Single<Credential.OAuthAccessToken> {
        fatalError("Not implementation")
    }
}
