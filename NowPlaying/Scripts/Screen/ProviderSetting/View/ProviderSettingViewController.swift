//
//  ProviderSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import UIKit

final class ProviderSettingViewController: FormViewController {

    private(set) var viewModel: ProviderSettingViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewModel.output.title.bind(to: rx.title)
        form = viewModel.output.form
    }
}

// MARK: - ProviderSettingViewer

extension ProviderSettingViewController: ProviderSettingViewer {}

extension ProviderSettingViewController {

    struct Dependency {
        let viewModel: ProviderSettingViewModelType
    }

    class func makeInstance(service: Service) -> ProviderSettingViewController {
        let viewController = ProviderSettingViewController()
        let router: ProviderSettingRouter
        let viewModel: ProviderSettingViewModelType

        switch service {
        case .twitter:
            router = TwitterSettingRouterImpl(view: viewController)
            viewModel = TwitterSettingViewModel(router: router)
        case .mastodon:
            router = MastodonSettingRouterImpl(view: viewController)
            viewModel = MastodonSettingViewModel(router: router)
        }

        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
