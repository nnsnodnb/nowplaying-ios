//
//  TwitterSettingRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

protocol TwitterSettingRoutable: Routable {
}

final class TwitterSettingRouter: TwitterSettingRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    // MARK: - Initialize
    init() {
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
