//
//  PostRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol PostViewer: UIViewController {}

enum AttachmentType {

    case artwork
    case screenshot
}

protocol PostRoutable: AnyObject {

    func dismissConfirm(didEdit: Bool)
    func pushChangeAccount(withService service: Service)
    func presentAttachmentActions(withImage image: UIImage, deletionHandler: @escaping () -> Void)
    func presentAddAttachmentActions(handler: @escaping (AttachmentType) -> Void)
}

final class PostRouter: PostRoutable {

    private(set) weak var view: PostViewer!

    init(view: PostViewer) {
        self.view = view
    }

    func dismissConfirm(didEdit: Bool) {
        if !didEdit {
            view.dismiss(animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(.init(title: "削除", style: .destructive) { [weak self] (_) in
            self?.view.dismiss(animated: true, completion: nil)
        })
        alert.preferredAction = alert.actions.last
        view.present(alert, animated: true, completion: nil)
    }

    func pushChangeAccount(withService service: Service) {
        print(#function)
    }

    func presentAttachmentActions(withImage image: UIImage, deletionHandler: @escaping () -> Void) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "プレビュー", style: .default) { [unowned self] (_) in
            let viewController = PreviewViewController.makeInstance(image: image)
            let navi = UINavigationController(rootViewController: viewController)
            navi.modalPresentationStyle = .currentContext
            navi.hero.isEnabled = true
            self.view.present(navi, animated: true, completion: nil)
        })
        actionSheet.addAction(.init(title: "添付画像を削除", style: .destructive) { (_) in
            deletionHandler()
        })
        actionSheet.addAction(.init(title: "閉じる", style: .cancel, handler: nil))
        view.present(actionSheet, animated: true, completion: nil)
    }

    func presentAddAttachmentActions(handler: @escaping (AttachmentType) -> Void) {
        let actionSheet = UIAlertController(title: "画像を追加します", message: "どちらを追加しますか？", preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "アートワーク", style: .default) { (_) in
            handler(.artwork)
        })
        actionSheet.addAction(.init(title: "再生画面のスクリーンショット", style: .default) { (_) in
            handler(.screenshot)
        })
        actionSheet.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        view.present(actionSheet, animated: true, completion: nil)
    }
}
