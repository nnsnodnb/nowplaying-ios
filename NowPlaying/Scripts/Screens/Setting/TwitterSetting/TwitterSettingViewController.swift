//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import PopupDialog
import DTTJailbreakDetection
import Eureka
import FirebaseAnalytics
import RxSwift
import SVProgressHUD
import StoreKit
import UIKit

final class TwitterSettingViewController: FormViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: TwitterSettingViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter設定"
        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem

        let inputs = TwitterSettingViewModelInput(viewController: self)
        viewModel = TwitterSettingViewModel(inputs: inputs)

        form = viewModel.form

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
            self.showBeforePurchaseNote()
        }
        alert.addAction(newPurchaseAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.preferredAction = newPurchaseAction
        present(alert, animated: true, completion: nil)
    }

    private func showBeforePurchaseNote() {
        let dialog = PopupDialog(title: nil,
                                 message: "iOS上での制約のため\n長時間には対応できません\n1〜2曲ごとにアプリを起動することで\n自動投稿可能です",
                                 buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: false,
                                 panGestureDismissal: false, hideStatusBar: true, completion: nil)

        let cancelButton = CancelButton(title: "キャンセル", action: nil)
        let purchaseButton = DefaultButton(title: "購入") { [unowned self] in
            self.viewModel.buyProduct(.autoTweet)
        }
        purchaseButton.titleFont = .boldSystemFont(ofSize: 15)
        dialog.addButtons([cancelButton, purchaseButton])
        let dialogVC = dialog.viewController as! PopupDialogDefaultViewController
        dialogVC.messageFont = .boldSystemFont(ofSize: 17)
        dialogVC.messageColor = .black
        DispatchQueue.main.async {
            self.present(dialog, animated: true, completion: nil)
        }
    }
}
