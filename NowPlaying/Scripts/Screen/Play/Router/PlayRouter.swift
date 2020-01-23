//
//  PlayRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol PlayViewer: UIViewController {}

protocol PlayRouter: AnyObject {

    init(view: PlayViewer)
    func openSetting()
    func openMastodon()
    func openTwitter()
}

final class PlayRouterImpl: PlayRouter {

    private(set) weak var view: PlayViewer!

    init(view: PlayViewer) {
        self.view = view
    }

    func openSetting() {
        let viewController = SettingViewController()
        let navi = UINavigationController(rootViewController: viewController)
        navi.modalPresentationStyle = .fullScreen
        view.present(navi, animated: true, completion: nil)
    }

    func openMastodon() {

    }

    func openTwitter() {

    }
}
