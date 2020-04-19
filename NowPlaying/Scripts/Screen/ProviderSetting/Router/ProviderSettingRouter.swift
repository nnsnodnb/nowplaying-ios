//
//  ProviderSettingRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol ProviderSettingViewer: UIViewController {}

protocol ProviderSettingRouter: AnyObject {}

final class TwitterSettingRouterImpl: ProviderSettingRouter {

    private(set) weak var view: ProviderSettingViewer!

    init(view: ProviderSettingViewer) {
        self.view = view
    }
}
