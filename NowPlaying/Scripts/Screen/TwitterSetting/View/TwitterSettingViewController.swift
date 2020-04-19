//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import UIKit

final class TwitterSettingViewController: FormViewController {

    private(set) var viewModel: TwitterSettingViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter設定"

        form = viewModel.output.form
    }
}

// MARK: - TwitterSettingViewer

extension TwitterSettingViewController: TwitterSettingViewer {}

extension TwitterSettingViewController {

    class func makeInstance() -> TwitterSettingViewController {
        let viewController = TwitterSettingViewController()
        let router = TwitterSettingRouterImpl(view: viewController)
        let viewModel = TwitterSettingViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    struct Dependency {
        let viewModel: TwitterSettingViewModelType
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
