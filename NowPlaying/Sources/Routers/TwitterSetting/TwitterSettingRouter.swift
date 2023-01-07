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

    private let environment: EnvironmentProtocol

    // MARK: - Initialize
    init(environment: EnvironmentProtocol) {
        self.environment = environment
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
