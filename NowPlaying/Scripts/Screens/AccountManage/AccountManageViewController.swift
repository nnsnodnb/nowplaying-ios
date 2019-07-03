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
    private let viewModel: AccountManageViewModelType
    private let disposeBag = DisposeBag()

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
        viewModel = AccountManageViewModel(service: service)
        super.init(nibName: R.nib.accountManageViewController.name, bundle: R.nib.accountManageViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
}
