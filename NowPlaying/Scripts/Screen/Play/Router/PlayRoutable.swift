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
    func openPostView(service: Service, item: MPMediaItem, screenshot: UIImage)
    func notExistServiceUser()
    func notAccessibleToMediaLibrary(status: MPMediaLibraryAuthorizationStatus)
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

    func openPostView(service: Service, item: MPMediaItem, screenshot: UIImage) {
        let viewController = PostViewController.makeInstance(service: service, item: item, screenshot: screenshot)
        let navi = UINavigationController(rootViewController: viewController)
        view.present(navi, animated: true, completion: nil)
    }

    func notExistServiceUser() {
        let alert = UIAlertController(title: "設定からログインしてください", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }

    func notAccessibleToMediaLibrary(status: MPMediaLibraryAuthorizationStatus) {
        let alert: UIAlertController
        switch status {
        case .denied:
            alert = .init(title: "アプリを使用するには\n許可が必要です",
                          message: "設定しますか？", preferredStyle: .alert)
            alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(.init(title: "設定する", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alert.preferredAction = alert.actions.last
        case .restricted:
            alert = .init(title: "本体に使用制限が設定されています",
                          message: "端末の管理者に解除を依頼してください", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
        default:
            return
        }
        view.present(alert, animated: true, completion: nil)
    }
}
