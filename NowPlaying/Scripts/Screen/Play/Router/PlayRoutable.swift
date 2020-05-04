//
//  PlayRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MediaPlayer
import UIKit

protocol PlayViewer: UIViewController {}

protocol PlayRoutable: AnyObject {

    init(view: PlayViewer)
    func openSetting()
    func openPostView(service: Service, item: MPMediaItem)
}

final class PlayRouter: PlayRoutable {

    private(set) weak var view: PlayViewer!

    init(view: PlayViewer) {
        self.view = view
    }

    func openSetting() {
        let viewController = SettingViewController.makeInstance()
        let navi = UINavigationController(rootViewController: viewController)
        view.present(navi, animated: true, completion: nil)
    }

    func openPostView(service: Service, item: MPMediaItem) {
        let viewController = PostViewController.makeInstance(service: service, item: item)
        let navi = UINavigationController(rootViewController: viewController)
        view.present(navi, animated: true, completion: nil)
    }
}
