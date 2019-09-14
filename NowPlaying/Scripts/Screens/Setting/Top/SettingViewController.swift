//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/22.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Eureka
import FirebaseAnalytics
import RxSwift
import StoreKit
import UIKit

final class SettingViewController: FormViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: SettingViewModel

    // MARK: - Initializer

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: R.nib.settingViewController.name, bundle: R.nib.settingViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "設定"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        closeButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = closeButton

        form = viewModel.form

        viewModel.outputs.startInAppPurchase
            .subscribe(onNext: { [weak self] (_) in
                self?.showSelectPurchaseType()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.pushViewController
            .drive(onNext: { [weak self] (viewController) in
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.presentViewController
            .drive(onNext: { [weak self] (viewController) in
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SKPaymentQueue.default().transactions.isEmpty { return }
        SKPaymentQueue.default().transactions
            .filter { $0.transactionState != .purchasing }
            .forEach { SKPaymentQueue.default().finishTransaction($0) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("設定画面", screenClass: "SettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
    }

    // MARK: - Private method

    private func showSelectPurchaseType() {
        let alert = UIAlertController(title: "復元しますか？購入しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "復元", style: .default) { [unowned self] (_) in
            self.viewModel.inputs.restoreTrigger.accept(())
        })
        let newPurchaseAction = UIAlertAction(title: "購入", style: .default) { [unowned self] (_) in
            self.viewModel.inputs.buyProductTrigger.accept(.hideAdmob)
        }
        alert.addAction(newPurchaseAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.preferredAction = newPurchaseAction
        present(alert, animated: true, completion: nil)
    }
}
