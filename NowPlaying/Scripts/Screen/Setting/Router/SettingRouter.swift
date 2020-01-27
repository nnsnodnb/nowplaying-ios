//
//  SettingRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/27.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol SettingViewer: UIViewController {}

protocol SettingRouter: AnyObject {

    init(view: SettingViewer)
}

final class SettingRouterImpl: SettingRouter {

    private(set) weak var view: SettingViewer!

    init(view: SettingViewer) {
        self.view = view
    }
}
