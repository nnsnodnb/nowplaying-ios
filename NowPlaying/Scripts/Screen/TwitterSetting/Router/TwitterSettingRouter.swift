//
//  TwitterSettingRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol TwitterSettingViewer: UIViewController {}

protocol TwitterSettingRouter: AnyObject {}

final class TwitterSettingRouterImpl: TwitterSettingRouter {

    private(set) weak var view: TwitterSettingViewer!

    init(view: TwitterSettingViewer) {
        self.view = view
    }
}
