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
}
