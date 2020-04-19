//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxDataSources
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

    private lazy var decideViewTransition: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel>.DecideViewTransition = { (dataSource, tableView, changesets) in
        if dataSource[0].items.isEmpty || changesets.isEmpty || changesets[0].movedItems.isEmpty { return .reload }
        return .animated
    }
    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel>.ConfigureCell = { (_, tableView, indexPath, item) in
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.accountManageTableViewCell, for: indexPath)!
        print(item)
        return cell
    }
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel> = .init(
        decideViewTransition: decideViewTransition, configureCell: configureCell
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        addBarButtonItem.rx.tap.bind(to: viewModel.input.addTrigger).disposed(by: disposeBag)
        editBarButtonItem.rx.tap.bind(to: viewModel.input.editTrigger).disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]

        viewModel.output.dataSources.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
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
