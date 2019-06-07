//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import FirebaseAnalytics
import RxSwift
import SVProgressHUD
import StoreKit
import UIKit

final class TwitterSettingViewController: FormViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: TwitterSettingViewModelType

    // MARK: - Initializer

    init(viewModel: TwitterSettingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: R.nib.twitterSettingViewController.name, bundle: R.nib.twitterSettingViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter設定"

        form = viewModel.form

        viewModel.outputs.presentViewController
            .drive(onNext: { [weak self] (viewController) in
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.startInAppPurchase
            .subscribe(onNext: { [weak self] (_) in
                self?.showSelectPurchaseType()
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("Twitter設定画面", screenClass: "TwitterSettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
    }

    // MARK: - Private method

    private func showSelectPurchaseType() {
        let alert = UIAlertController(title: "復元しますか？購入しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "復元", style: .default) { [unowned self] (_) in
            self.viewModel.restore()
        })
        let newPurchaseAction = UIAlertAction(title: "購入", style: .default) { [unowned self] (_) in
            self.viewModel.buyProduct(.autoTweet)
        }
        alert.addAction(newPurchaseAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.preferredAction = newPurchaseAction
        present(alert, animated: true, completion: nil)
    }
}
