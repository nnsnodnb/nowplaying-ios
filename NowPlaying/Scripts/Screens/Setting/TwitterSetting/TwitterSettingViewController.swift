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

    private var isProces = false
    private var productRequest: SKProductsRequest?
    private var autoTweetProduct: SKProduct?
    private var viewModel: TwitterSettingViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter設定"

        viewModel = TwitterSettingViewModel()

        form = viewModel.form

        viewModel.outputs.presentViewController
            .drive(onNext: { [weak self] (viewController) in
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        setupProducts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("Twitter設定画面", screenClass: "TwitterSettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
    }

    // MARK: - Private method

    private func showSelectPurchaseType(product: SKProduct) {
        let alert = UIAlertController(title: "復元しますか？購入しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "復元", style: .default) { (_) in
//            PaymentManager.shared.startRestore()
        })
        let newPurchaseAction = UIAlertAction(title: "購入", style: .default) { (_) in
//            PaymentManager.shared.buyProduct(product)
        }
        alert.addAction(newPurchaseAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { [unowned self] (_) in
            self.isProces = false
        })
        alert.preferredAction = newPurchaseAction
        present(alert, animated: true, completion: nil)
    }

    private func setupProducts() {
        if UserDefaults.bool(forKey: .isAutoTweetPurchase) {
            return
        }
//        PaymentManager.shared.delegate = self
//        let productId = Set(arrayLiteral: "moe.nnsnodnb.NowPlaying.autoTweet")
//        SVProgressHUD.show()
//        productRequest = PaymentManager.shared.startProductRequest(productId)
    }

    private func completePuchaseAutoTweet() {
        UserDefaults.set(true, forKey: .isAutoTweetPurchase)
        DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss(withDelay: 0.5)
            guard let wself = self else { return }
            wself.isProces = false
            let purchaseButtonRow: ButtonRow = wself.form.rowBy(tag: "auto_tweet_purchase")!
            let autoTweetSwitchRow: SwitchRow = wself.form.rowBy(tag: "auto_tweet_switch")!
            purchaseButtonRow.hidden = Condition(booleanLiteral: true)
            purchaseButtonRow.evaluateHidden()
            autoTweetSwitchRow.evaluateHidden()
        }
    }
}

// MARK: - PaymentManagerProtocol

//extension TwitterSettingViewController: PaymentManagerProtocol {
//
//    func finish(request: SKProductsRequest, products: [SKProduct]) {
//        autoTweetProduct = products.first
//        SVProgressHUD.dismiss()
//    }
//
//    func finish(request: SKRequest, didFailWithError: Error) {
//        SVProgressHUD.showError(withStatus: "通信エラーが発生しました")
//        SVProgressHUD.dismiss(withDelay: 0.3)
//    }
//
//    func finish(success paymentTransaction: SKPaymentTransaction) {
//        DispatchQueue.main.async {
//            SVProgressHUD.show()
//        }
//        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptUrl, options: .uncached) else { return }
//        let request = PurchaseRequest(receiptData: receiptData.base64EncodedString())
//        request.send { [weak self] (result) in
//            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//            }
//            switch result {
//            case .success(let response):
//                guard let body = response.body, let status = body["status"] as? Int,
//                    let wself = self, status == 0 else {
//                        return
//                }
//                wself.completePuchaseAutoTweet()
//            case .failure:
//                SVProgressHUD.showError(withStatus: "検証に失敗しました")
//                SVProgressHUD.dismiss(withDelay: 0.3)
//            }
//        }
//    }
//
//    func finishPayment(failed paymentTransaction: SKPaymentTransaction) {
//        isProces = false
//        DispatchQueue.main.async {
//            SVProgressHUD.showError(withStatus: "購入に失敗しました")
//            SVProgressHUD.dismiss(withDelay: 0.3)
//        }
//    }
//
//    func finishRestore(queue: SKPaymentQueue) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            SVProgressHUD.dismiss {
//                SVProgressHUD.showInfo(withStatus: "復元に成功しました")
//            }
//        }
//        completePuchaseAutoTweet()
//        isProces = false
//    }
//
//    func finishRestore(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {
//        isProces = false
//        DispatchQueue.main.async {
//            SVProgressHUD.showError(withStatus: "復元に失敗しました")
//            SVProgressHUD.dismiss(withDelay: 0.3)
//        }
//    }
//}
