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
import RxSwift
import SafariServices
import SVProgressHUD
import UIKit
import Umbrella

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

            tableView.rx.realmModelSelected(User.self).bind(to: viewModel.input.cellSelected).disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private(set) var viewModel: AccountManageViewModelType!

    private lazy var dataSource: RxTableViewRealmDataSource<User> = {
        return .init(cellIdentifier: R.reuseIdentifier.accountManageTableViewCell.identifier, cellType: AccountManageTableViewCell.self) {
            $0.user = $2
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: nil, action: nil)
        editBarButtonItem.possibleTitles = ["編集", "完了"]
        addBarButtonItem.rx.tap.bind(to: viewModel.input.addTrigger).disposed(by: disposeBag)
        editBarButtonItem.rx.tap.bind(to: viewModel.input.editTrigger).disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]

        viewModel.output.dataSource.bind(to: tableView.rx.realmChanges(dataSource)).disposed(by: disposeBag)
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
                SVProgressHUD.dismiss(withDelay: 2)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.selectedMastodonInstance)
            .subscribe(onNext: { (_) in
                SVProgressHUD.show()
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
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "ログアウト") { [unowned self] (_, indexPath) in
            let user = self.dataSource.model(at: indexPath)
            self.viewModel.input.deleteTrigger.accept(user)
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
        let router: AccountManageRoutable
        let viewModel: AccountManageViewModelType

        switch service {
        case .twitter:
            router = TwitterAccountManageRouter(view: viewController)
            viewModel = TwitterAccountManageViewModel(router: router)
        case .mastodon:
            router = MastodonAccountManageRouter(view: viewController)
            viewModel = MastodonAccountManageViewModel(router: router)
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
