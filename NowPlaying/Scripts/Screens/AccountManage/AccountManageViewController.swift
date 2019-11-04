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
import RxRealm
import RxSwift
import SafariServices
import SVProgressHUD
import UIKit

final class AccountManageViewController: UIViewController {

    private let viewModel: AccountManageViewModelType
    private let service: Service
    private let screenType: ScreenType
    private let selectionTrigger = PublishSubject<User>()
    private let disposeBag = DisposeBag()

    let selection: Observable<User>

    private lazy var users: Results<User> = {
        let realm = try! Realm(configuration: realmConfiguration)
        return realm.objects(User.self)
            .filter("serviceType = %@", service.rawValue)
            .sorted(byKeyPath: "id", ascending: true)
    }()

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.accountManageTableViewCell)
            tableView.tableFooterView = UIView()
            tableView.rx.setDataSource(self).disposed(by: disposeBag)
            tableView.rx.setDelegate(self).disposed(by: disposeBag)
        }
    }

    // MARK: - Initializer

    init(viewModel: AccountManageViewModelType, service: Service, screenType: ScreenType) {
        self.viewModel = viewModel
        self.service = service
        self.screenType = screenType
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

        viewModel.outputs.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        Observable.changeset(from: users)
            .subscribe(onNext: { [tableView] (_, changes) in
                if let changes = changes {
                    tableView?.applyChangeset(changes)
                } else {
                    tableView?.reloadData()
                }
            })
            .disposed(by: disposeBag)

        subscribeViewModelOutput()
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
                    self.viewModel.inputs.twitterLoginTrigger.accept(self)
                case .mastodon:
                    let viewController = SearchMastodonViewController(viewModel: SearchMastodonViewModel())
                    _ = viewController.decision
                        .subscribe(onNext: { [unowned self] (hostname) in
                            
                        })
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

    private func subscribeViewModelOutput() {
        viewModel.outputs.loginResult
            .subscribe(onNext: { [unowned self] (result) in
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

        viewModel.outputs.removeResult
            .subscribe(onError: { (error) in
                print(error)
                SVProgressHUD.showError(withStatus: "ログアウトに失敗しました")
            }, onCompleted: { [weak self] in
                Feeder.Impact(.medium).impactOccurred()
                SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                SVProgressHUD.dismiss(withDelay: 1) { [weak self] in
                    self?.viewModel.inputs.newDefaultAccountTrigger.accept(())
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.newDefaultAccount
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (alert) in
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.tokenRevokeResult
            .subscribe(onNext: { [weak self] (user) in
                self?.viewModel.inputs.removeUserDataTrigger.accept(user)
            }, onError: { (error) in
                Feeder.Notification(.error).notificationOccurred()
                print(error)
                SVProgressHUD.showError(withStatus: "ログアウトに失敗しました")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension AccountManageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.accountManageTableViewCell, for: indexPath)!
        let user = users[indexPath.row]
        cell.configure(user: user, secret: user.secretCredentials.first!)
        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return screenType == .settings ? .delete : .none
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete { return }
        let realm = try! Realm(configuration: realmConfiguration)
        let user = realm.object(ofType: User.self, forPrimaryKey: users[indexPath.row].id)!
        SVProgressHUD.show()
        if user.isTwitterUser {
            viewModel.inputs.removeUserDataTrigger.accept(user)
            return
        }
        viewModel.inputs.tokenRevokeTrigger.accept(user.secretCredentials.first!)
    }
}

// MARK: - UITableViewDelegate

extension AccountManageViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Feeder.Selection().selectionChanged()
        let user = users[indexPath.row]
        switch screenType {
        case .settings:
            if !user.isDefault { user.isDefaultAccount = true }
        case .selection:
            selectionTrigger.onNext(user)
            selectionTrigger.onCompleted()
            navigationController?.popViewController(animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

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
