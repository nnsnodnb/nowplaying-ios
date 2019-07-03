//
//  AccountManageViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit
import RxSwift

final class AccountManageViewController: UIViewController {

    private let service: Service
    private let viewModel: AccountManageViewModelType
    private let disposeBag = DisposeBag()

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
    }
}
