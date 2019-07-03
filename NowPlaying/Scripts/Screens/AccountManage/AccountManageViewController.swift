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
import UIKit

final class AccountManageViewController: UIViewController {

    private let service: Service
    private let disposeBag = DisposeBag()

    private var viewModel: AccountManageViewModelType!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.accountManageTableViewCell)
            tableView.tableFooterView = UIView()

            tableView.rx.modelSelected(User.self)
                .subscribe(onNext: { (user) in
                    print(user.name)
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

    struct Difference {
        let target: Results<User>
        let source: Results<User>
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
                cell.user = $1
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Private method

    private func setupNavigationBar() -> AccountManageViewModelInput {
        let addAccountBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editAccountsBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)

        navigationItem.rightBarButtonItems = [editAccountsBarButtonItem, addAccountBarButtonItem]

        return .init(service: service,
                     addAccountBarButtonItem: addAccountBarButtonItem.rx.tap.asObservable(),
                     editAccountsBarButtonItem: editAccountsBarButtonItem.rx.tap.asObservable())
    }
}
