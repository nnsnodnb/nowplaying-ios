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

    func showUpdateAlert(isRequired: Bool) {
        let title: String = isRequired ? "アップデートが必要です" : "アップデートがあります"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let tapHandler: (() -> Void)?
        if isRequired {
            tapHandler = { [unowned self] in
                self.showUpdateAlert(isRequired: true)
            }
        } else {
            tapHandler = nil
            alert.addAction(.init(title: "あとで", style: .default, handler: nil))
        }

        let openAction = UIAlertAction(title: "AppStoreを開く", style: .default) { (_) in
            UIApplication.shared.open(URL(string: websiteURL)!, options: [:], completionHandler: nil)
            tapHandler?()
        }

        alert.addAction(openAction)
        alert.preferredAction = openAction

        DispatchQueue.main.async {
            self.window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
