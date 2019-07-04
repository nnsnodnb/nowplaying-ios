//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import UIKit

final class AccountManageViewController: UIViewController {

    private let service: Service
    private let disposeBag = DisposeBag()

    private var viewModel: AccountManageViewModelType!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.accountManageTableViewCell)
            tableView.tableFooterView = UIView()

            tableView.rx.modelDeleted(User.self)
                .subscribe(onNext: { [unowned self] in
                    let realm = try! Realm(configuration: realmConfiguration)
                    let user = realm.object(ofType: User.self, forPrimaryKey: $0.id)!
                    SVProgressHUD.show()
                    if user.isTwitetrUser {
                        self.removeUserData(user: user)
                        return
                    }
                    self.viewModel.tokenRevoke(secret: user.secretCredentials.first!)
                        .subscribe(onNext: { [weak self] (_) in
                            self?.removeUserData(user: user)
                        }, onError: { (error) in
                            print(error)
                            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました")
                            SVProgressHUD.dismiss(withDelay: 1)
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Initializer

    init(service: Service) {
        self.service = service
        super.init(nibName: R.nib.accountManageViewController.name, bundle: R.nib.accountManageViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let inputs = setupNavigationBar()

        viewModel = AccountManageViewModel(inputs: inputs)

        viewModel.outputs.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.users
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.accountManageTableViewCell.identifier)) {
                guard let cell = $2 as? AccountManageTableViewCell else { return }
                cell.configure(user: $1, secret: $1.secretCredentials.first)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.loginResult
            .subscribe(onNext: { (result) in
                switch result {
                case .success(let user):
                    SVProgressHUD.showSuccess(withStatus: "\(user.screenName)にログインしました")
                case .failure:
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました")
                case .duplicate:
                    SVProgressHUD.showInfo(withStatus: "すでにログインされているアカウントです")
                }
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Override method

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = isEditing
    }

    // MARK: - Private method

    private func setupNavigationBar() -> AccountManageViewModelInput {
        let addAccountBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editAccountsBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: nil, action: nil)
        editAccountsBarButtonItem.possibleTitles = ["編集", "完了"]

        navigationItem.rightBarButtonItems = [editAccountsBarButtonItem, addAccountBarButtonItem]

        return .init(service: service, addAccountBarButtonItem: addAccountBarButtonItem,
                     editAccountsBarButtonItem: editAccountsBarButtonItem, viewController: self)
    }

    private func removeUserData(user: User) {
        do {
            let realm = try Realm(configuration: realmConfiguration)
            try realm.write {
                realm.delete(user.secretCredentials.first!)
                realm.delete(user)
            }
            SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
            SVProgressHUD.dismiss(withDelay: 1)
        } catch {
            print(error)
        }
    }
}

// MARK: - SFSafariViewControllerDelegate

// FIXME: SFSafariViewControllerの戻るボタンを隠す
extension AccountManageViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        SVProgressHUD.showInfo(withStatus: "ログインをキャンセルしました")
        SVProgressHUD.dismiss(withDelay: 1)
    }
}
