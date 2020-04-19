//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class AccountManageViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.register(R.nib.accountManageTableViewCell)
        }
    }

    private let disposeBag = DisposeBag()

    private(set) var viewModel: AccountManageViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]
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
