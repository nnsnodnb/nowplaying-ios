//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Feeder
import RealmSwift
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
            tableView.rx.setDelegate(self).disposed(by: disposeBag)

            tableView.rx.itemSelected
                .do(onNext: { (_) in
                    Feeder.Selection().selectionChanged()
                })
                .subscribe(onNext: { [unowned tableView] in
                    tableView?.deselectRow(at: $0, animated: true)
                })
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(User.self).bind(to: viewModel.input.changeDefaultAccount).disposed(by: disposeBag)

            tableView.rx.modelDeleted(User.self)
                .subscribe(onNext: { (user) in
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
    private lazy var canEditRowAtIndexPath: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel>.CanEditRowAtIndexPath = { (_, _) in
        return true
    }
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<AccountManageSectionModel> = .init(
        configureCell: configureCell, canEditRowAtIndexPath: canEditRowAtIndexPath
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: nil, action: nil)
        editBarButtonItem.possibleTitles = ["編集", "完了"]
        addBarButtonItem.rx.tap.bind(to: viewModel.input.addTrigger).disposed(by: disposeBag)
        editBarButtonItem.rx.tap.bind(to: viewModel.input.editTrigger).disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]

        viewModel.output.dataSources.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.output.loginSuccess
            .do(onNext: { (_) in
                Feeder.Notification(.success).notificationOccurred()
            })
            .subscribe(onNext: { (screenName) in
                SVProgressHUD.showSuccess(withStatus: "\(screenName)さんでログインしました！")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)

        viewModel.output.loginError
            .do(onNext: {
                print($0)
                Feeder.Notification(.error).notificationOccurred()
            })
            .subscribe(onNext: { (message) in
                SVProgressHUD.showError(withStatus: message)
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)

        viewModel.output.changedDefaultAccount
            .map { _ in }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadSections([0], animationStyle: .none)
            })
            .disposed(by: disposeBag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = isEditing
        navigationItem.rightBarButtonItems?.first?.title = isEditing ? "完了" : "編集"
    }
}

// MARK: - UITableViewDelegate

extension AccountManageViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "ログアウト") { (_, indexPath) in
            tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
        }
        return [deleteRowAction]
    }
}

// MARK: - SFSafariViewControllerDelegate

extension AccountManageViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        Feeder.Impact(.medium).impactOccurred()
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

// MARK: - AccountManageViewer

extension AccountManageViewController: AccountManageViewer {}
