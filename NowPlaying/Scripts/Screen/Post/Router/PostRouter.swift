//
//  PostRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol PostViewer: UIViewController {}

protocol PostRoutable: AnyObject {

    func dismissConfirm(didEdit: Bool)
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
}
