//
//  SearchMastodonRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol SearchMastodonViewer: UIViewController {}

protocol SearchMastodonRoutable: AnyObject {

    init(view: SearchMastodonViewer)
    func showConfirm(toInstance instnace: Instance)
}

final class SearchMastodonRouter: SearchMastodonRoutable {

    private(set) weak var view: SearchMastodonViewer!

    init(view: SearchMastodonViewer) {
        self.view = view
    }

    func showConfirm(toInstance instance: Instance) {
        let alert = UIAlertController(title: "\(instance.name)\nこのインスタンスに設定します", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(.init(title: "OK", style: .default) { (_) in
            UIView.animate(withDuration: 0, animations: { [weak self] in
                self?.view.navigationController?.popViewController(animated: true)
            }, completion: { (_) in
                NotificationCenter.default.post(name: .selectedMastodonInstance, object: instance)
            })
        })
        alert.preferredAction = alert.actions.last

        view.present(alert, animated: true, completion: nil)
    }
}
