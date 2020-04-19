//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class AccountManageViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private(set) var viewModel: AccountManageViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - AccountManageViewer

extension AccountManageViewController: AccountManageViewer {}

extension AccountManageViewController {

    enum Provider {
        case twitter
        case mastodon
    }

    struct Dependency {
        let viewModel: AccountManageViewModelType
    }

    class func makeInstance(provider: Provider) -> AccountManageViewController {
        let viewController = AccountManageViewController()
        let router = AccountManageRouterImpl(view: viewController)
        let viewModel = AccountManageViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
