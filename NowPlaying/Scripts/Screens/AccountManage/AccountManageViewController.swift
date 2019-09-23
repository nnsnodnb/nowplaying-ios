//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Feeder
import RealmSwift
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import UIKit

final class AccountManageViewController: UIViewController {

    struct Input {
        let viewModel: AccountManageViewModelType
        let service: Service
        let screenType: ScreenType
    }

    private let viewModel: AccountManageViewModelType
    private let service: Service
    private let screenType: ScreenType
    private let selectionTrigger = PublishSubject<User>()
    private let disposeBag = DisposeBag()

    let selection: Observable<User>

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.accountManageTableViewCell)
            tableView.tableFooterView = UIView()
            tableView.rx.setDelegate(self).disposed(by: disposeBag)

            tableView.rx.itemSelected
                .subscribe(onNext: { [tableView] (indexPath) in
                    tableView?.deselectRow(at: indexPath, animated: true)
                })
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(User.self)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] in
                    Feeder.Selection().selectionChanged()
                    switch self.screenType {
                    case .settings:
                        if !$0.isDefault { $0.isDefaultAccount = true }
                    case .selection:
                        self.selectionTrigger.onNext($0)
                        self.selectionTrigger.onCompleted()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                .disposed(by: disposeBag)

            if screenType == .selection { return }
            tableView.rx.modelDeleted(User.self)
                .subscribe(onNext: { [unowned self] in
                    let realm = try! Realm(configuration: realmConfiguration)
                    let user = realm.object(ofType: User.self, forPrimaryKey: $0.id)!
                    SVProgressHUD.show()
                    if user.isTwitetrUser {
                        self.removeUserData(user: user)
                        return
                    }
                    _ = self.viewModel.tokenRevoke(secret: user.secretCredentials.first!)
                        .subscribe(onNext: { [weak self] (_) in
                            self?.removeUserData(user: user)
                        }, onError: { (error) in
                            Feeder.Notification(.error).notificationOccurred()
                            print(error)
                            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました")
                            SVProgressHUD.dismiss(withDelay: 1)
                        })
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Initializer

    init(input: Input) {
        viewModel = input.viewModel
        service = input.service
        screenType = input.screenType
        selection = selectionTrigger.asObserver()
        super.init(nibName: R.nib.accountManageViewController.name, bundle: R.nib.accountManageViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        _ = viewModel.outputs.title
            .bind(to: navigationItem.rx.title)

        viewModel.outputs.users
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.accountManageTableViewCell.identifier)) {
                guard let cell = $2 as? AccountManageTableViewCell else { return }
                cell.configure(user: $1, secret: $1.secretCredentials.first)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.loginResult
            .subscribe(onNext: { (result) in
                var completion: SVProgressHUDDismissCompletion?
                switch result {
                case .initial(let user):
                    completion = { [weak self] in
                        let alert = UIAlertController(title: "デフォルトアカウント変更", message: "\(user.name)に設定されました", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                    fallthrough
                case .success(let user):
                    Feeder.Notification(.success).notificationOccurred()
                    SVProgressHUD.showSuccess(withStatus: "\(user.screenName)にログインしました")
                case .failure:
                    Feeder.Notification(.error).notificationOccurred()
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました")
                case .duplicate:
                    Feeder.Notification(.warning).notificationOccurred()
                    SVProgressHUD.showInfo(withStatus: "すでにログインされているアカウントです")
                }
                SVProgressHUD.dismiss(withDelay: 1, completion: completion)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Override method

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = isEditing
    }

    // MARK: - Private method

    private func setupNavigationBar() {
        let addAccountBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editAccountsBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: nil, action: nil)
        editAccountsBarButtonItem.possibleTitles = ["編集", "完了"]

        if screenType == .settings {
            navigationItem.rightBarButtonItems = [editAccountsBarButtonItem, addAccountBarButtonItem]
        }

        addAccountBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] in
                Feeder.Impact(.light).impactOccurred()
                switch self.service {
                case .twitter:
                    SVProgressHUD.show()
                    // TODO: Twitterログインスタート
                case .mastodon:
                    // TODO: Mastodonログインスタート
                    break
                }
            })
            .disposed(by: disposeBag)

        editAccountsBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] in
                let isEditing = !self.isEditing
                self.setEditing(isEditing, animated: true)
                let newTitle = isEditing ? "完了" : "編集"
                editAccountsBarButtonItem.title = newTitle
            })
            .disposed(by: disposeBag)
    }

    private func removeUserData(user: User) {
        _ = viewModel.removeUserData(user)
            .subscribe(onCompleted: {
                Feeder.Impact(.medium).impactOccurred()
                SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                SVProgressHUD.dismiss(withDelay: 1) { [weak self] in
                    _ = self?.viewModel.applyNewDefaultAccount()
                        .observeOn(MainScheduler.instance)
                        .subscribe(onNext: { (alert) in
                            self?.present(alert, animated: true, completion: nil)
                        })
                }
            })
    }
}

// MARK: - UITableViewDelegate

extension AccountManageViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if screenType == .selection { return nil }
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

    enum ScreenType {
        case settings
        case selection
    }
}
