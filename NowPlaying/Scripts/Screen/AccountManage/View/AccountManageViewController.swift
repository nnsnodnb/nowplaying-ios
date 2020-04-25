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
import SafariServices
import SVProgressHUD
import UIKit

final class AccountManageViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.register(R.nib.accountManageTableViewCell)

            tableView.rx.itemSelected
                .subscribe(onNext: { [unowned tableView] in
                    tableView?.deselectRow(at: $0, animated: true)
                })
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(User.self)
                .subscribe(onNext: { (user) in
                    print(user)
                })
                .disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private(set) var viewModel: AccountManageViewModelType!

    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel>.ConfigureCell = { (_, tableView, indexPath, item) in
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.accountManageTableViewCell, for: indexPath)!
        cell.user = item
        return cell
    }
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel> = .init(configureCell: configureCell)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        addBarButtonItem.rx.tap.bind(to: viewModel.input.addTrigger).disposed(by: disposeBag)
        editBarButtonItem.rx.tap.bind(to: viewModel.input.editTrigger).disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]

        viewModel.output.dataSources.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.output.loginSuccess
            .subscribe(onNext: { (screenName) in
                SVProgressHUD.showSuccess(withStatus: "\(screenName)さんでログインしました！")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)

        viewModel.output.loginError
            .do(onNext: {
                print($0)
            })
            .subscribe(onNext: { (message) in
                SVProgressHUD.showError(withStatus: message)
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewer

extension AccountManageViewController: AccountManageViewer {}

// MARK: - SFSafariViewControllerDelegate

extension AccountManageViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        SVProgressHUD.showInfo(withStatus: "ログインをキャンセルしました")
        SVProgressHUD.dismiss(withDelay: 1)
    }
}

extension AccountManageViewController {

    struct Dependency {
        let viewModel: AccountManageViewModelType
    }

    class func makeInstance(service: Service) -> AccountManageViewController {
        let viewController = AccountManageViewController()
        let router: AccountManageRouter
        let viewModel: AccountManageViewModelType

        switch service {
        case .twitter:
            router = TwitterAccountManageRouterImpl(view: viewController)
            viewModel = TwitterAccountManageViewModel(router: router)
        case .mastodon:
            router = AccountManageRouterImpl(view: viewController)
            viewModel = AccountManageViewModel(router: router)
        }

        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
