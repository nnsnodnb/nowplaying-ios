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

    enum Screen: Equatable {
        case list(Service)
        case manage(Service)

        var isManage: Bool {
            if case .manage = self { return true }
            return false
        }
    }

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

            tableView.rx.realmModelSelected(User.self).bind(to: viewModel.inputs.cellSelected).disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()
    private let isManage: Bool

    private(set) var viewModel: AccountManageViewModelType!

    private lazy var dataSource: RxTableViewRealmDataSource<User> = {
        return .init(cellIdentifier: R.reuseIdentifier.accountManageTableViewCell.identifier, cellType: AccountManageTableViewCell.self) {
            $0.user = $2
        }
    }()

    // MARK: - Initializer

    init(isManage: Bool) {
        self.isManage = isManage
        super.init(nibName: R.nib.accountManageViewController.name, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アカウント管理"

        if isManage {
            let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
            let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: nil, action: nil)
            editBarButtonItem.possibleTitles = ["編集", "完了"]
            addBarButtonItem.rx.tap.bind(to: viewModel.inputs.addTrigger).disposed(by: disposeBag)
            editBarButtonItem.rx.tap.bind(to: viewModel.inputs.editTrigger).disposed(by: disposeBag)
            navigationItem.rightBarButtonItems = [editBarButtonItem, addBarButtonItem]
        }

        viewModel.outputs.dataSource.bind(to: tableView.rx.realmChanges(dataSource)).disposed(by: disposeBag)
        viewModel.outputs.loginSuccess
            .do(onNext: { (_) in
                Feeder.Notification(.success).notificationOccurred()
            })
            .subscribe(onNext: { (screenName) in
                SVProgressHUD.showSuccess(withStatus: "\(screenName)さんでログインしました！")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.loginError
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
        guard isManage else { return nil }
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "ログアウト") { [unowned self] (_, indexPath) in
            let user = self.dataSource.model(at: indexPath)
            self.viewModel.inputs.deleteTrigger.accept(user)
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
        let screen: Screen
    }

    class func makeInstance(screen: Screen, selectHandler: ((User) -> Void)? = nil) -> AccountManageViewController {
        let viewController = AccountManageViewController(isManage: screen.isManage)
        let router: AccountManageRoutable
        let viewModel: AccountManageViewModelType

        switch screen {
        case .list(let service):
            router = AccountListRouter(view: viewController)
            viewModel = AccountListViewModel(router: router, service: service) { selectHandler?($0) }

        case .manage(let service):
            switch service {
            case .twitter:
                router = TwitterAccountManageRouter(view: viewController)
                viewModel = TwitterAccountManageViewModel(router: router)
            case .mastodon:
                router = MastodonAccountManageRouter(view: viewController)
                viewModel = MastodonAccountManageViewModel(router: router)
            }

        }

        viewController.inject(dependency: .init(viewModel: viewModel, screen: screen))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}

// MARK: - AccountManageViewer

extension AccountManageViewController: AccountManageViewer {}
