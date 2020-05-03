//
//  ApplicationCoordinator.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class ApplicationCoordinator {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = PlayViewController()
        let router = PlayRouter(view: viewController)
        let viewModel = PlayViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
