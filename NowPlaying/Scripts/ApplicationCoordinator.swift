//
//  ApplicationCoordinator.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class ApplicationCoordinator {

    private let window: UIWindow
    private let twitterNowPlayingCore: NowPlayingCoreType = TwitterNowPlayingCore()
    private let mastodonNowPlayingCore: NowPlayingCoreType = MastodonNowPlayingCore()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = PlayViewController.makeInstance()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
