//
//  UIAlertController+Common.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

extension UIAlertController {

    class func jailBreak() -> UIAlertController {
        let alert = UIAlertController(title: "脱獄が検知されました",
                                      message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .cancel, handler: nil))
        return alert
    }

    class func resetPostFormat(confirmHandler: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "投稿フォーマットをリセットします", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(.init(title: "リセット", style: .destructive) { (_) in
            confirmHandler?()
        })
        return alert
    }

    class func confirmAutoTweetUsageInformation(confirmHandler: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "iOS上での制約のため\n長時間には対応できません\n1〜2曲ごとにアプリを起動することで\n自動投稿可能です",
                                      message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(.init(title: "購入する", style: .default) { (_) in
            confirmHandler()
        })
        alert.preferredAction = alert.actions.last
        return alert
    }
}
