//
//  AccoutManageRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol AccountManageViewer: UIViewController {}

protocol AccountManageRouter: AnyObject {

    init(view: AccountManageViewer)
}

final class AccountManageRouterImpl: AccountManageRouter {

    private(set) weak var view: AccountManageViewer!

    init(view: AccountManageViewer) {
        self.view = view
    }
}
