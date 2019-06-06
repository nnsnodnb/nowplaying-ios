//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/22.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Eureka
import FirebaseAnalytics
import KeychainAccess
import NSURL_QueryDictionary
import RxSwift
import StoreKit
import SVProgressHUD
import UIKit

final class SettingViewController: FormViewController {

    private let keychain = Keychain(service: keychainServiceKey)
    private let disposeBag = DisposeBag()

    private var isProcess = false
    private var productRequest: SKProductsRequest?
    private var products = [SKProduct]()
    private var purchasingProduct: SKProduct?
    private var viewModel: SettingViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupProducts()

        viewModel = SettingViewModel()

        form = viewModel.form

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
        if SKPaymentQueue.default().transactions.count <= 0 {
            return
        }
        for transaction in SKPaymentQueue.default().transactions where transaction.transactionState != .purchasing {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("設定画面", screenClass: "SettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: receiveSafariNotificationName, object: nil)
    }

    // MARK: - Private method

    private func setupNavigationbar() {
        title = "設定"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onTapCloseButton(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }

    private func setupProducts() {
        if UserDefaults.bool(forKey: .isAutoTweetPurchase) && UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) {
            return
        }
        PaymentManager.shared.delegate = self
        let productIds = Set(arrayLiteral: "moe.nnsnodnb.NowPlaying.autoTweet", "moe.nnsnodnb.NowPlaying.hideAdMob")
        SVProgressHUD.show()
        productRequest = PaymentManager.shared.startProductRequest(productIds)
    }

    private func showSelectPurchaseType(product: SKProduct) {
        purchasingProduct = product
        let alert = UIAlertController(title: "復元しますか？購入しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "復元", style: .default) { (_) in
            PaymentManager.shared.startRestore()
        })
        let newPurchaseAction = UIAlertAction(title: "購入", style: .default) { (_) in
            PaymentManager.shared.buyProduct(product)
        }
        alert.addAction(newPurchaseAction)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { [unowned self] (_) in
            self.isProcess = false
        })
        alert.preferredAction = newPurchaseAction
        present(alert, animated: true, completion: nil)
    }

    private func completePuchaseAutoTweet() {
        UserDefaults.set(true, forKey: .isAutoTweetPurchase)
        DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss()
            guard let wself = self else { return }
            wself.isProcess = false
            wself.purchasingProduct = nil
            let purchaseButtonRow: ButtonRow = wself.form.rowBy(tag: "auto_tweet_purchase")!
            let autoTweetSwitchRow: SwitchRow = wself.form.rowBy(tag: "auto_tweet_switch")!
            purchaseButtonRow.hidden = Condition(booleanLiteral: true)
            purchaseButtonRow.evaluateHidden()
            autoTweetSwitchRow.evaluateHidden()
        }
    }

    private func completePurchaseRemoveAdmob() {
        UserDefaults.set(true, forKey: .isPurchasedRemoveAdMob)
        DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss()
            guard let wself = self, let purchaseButtonRow: ButtonRow = wself.form.rowBy(tag: "remove_admob") else { return }
            wself.isProcess = false
            wself.purchasingProduct = nil
            purchaseButtonRow.hidden = Condition(booleanLiteral: true)
            purchaseButtonRow.evaluateHidden()
        }
    }

    // MARK: - UIBarButtonItem target

    @objc private func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PaymentManagerProtocol

extension SettingViewController: PaymentManagerProtocol {

    func finish(request: SKProductsRequest, products: [SKProduct]) {
        if products.first!.productIdentifier == "moe.nnsnodnb.NowPlaying.autoTweet" {
            self.products = [products.first!, products.last!]
        } else {
            self.products = [products.last!, products.first!]
        }
        SVProgressHUD.dismiss()
    }

    func finish(request: SKRequest, didFailWithError: Error) {
        SVProgressHUD.showError(withStatus: "通信エラーが発生しました")
        SVProgressHUD.dismiss(withDelay: 0.3)
    }

    func finish(success paymentTransaction: SKPaymentTransaction) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            SVProgressHUD.show()
            guard let receiptUrl = Bundle.main.appStoreReceiptURL,
                let receiptData = try? Data(contentsOf: receiptUrl, options: .uncached) else { return }
            let request = PurchaseRequest(receiptData: receiptData.base64EncodedString())
            request.send { [weak self] (result) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                switch result {
                case .success(let response):
                    guard let body = response.body, let status = body["status"] as? Int,
                        let wself = self, let purchasingProduct = wself.purchasingProduct, status == 0 else {
                            return
                    }
                    if purchasingProduct.productIdentifier == "moe.nnsnodnb.NowPlaying.autoTweet" {
                        wself.completePuchaseAutoTweet()
                    } else if purchasingProduct.productIdentifier == "moe.nnsnodnb.NowPlaying.hideAdMob" {
                        wself.completePurchaseRemoveAdmob()
                    }
                case .failure:
                    SVProgressHUD.showError(withStatus: "検証に失敗しました")
                    SVProgressHUD.dismiss(withDelay: 0.3)
                }
            }
        }
    }

    func finishPayment(failed paymentTransaction: SKPaymentTransaction) {
        purchasingProduct = nil
        isProcess = false
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: "購入に失敗しました")
            SVProgressHUD.dismiss(withDelay: 0.3)
        }
    }

    func finishRestore(queue: SKPaymentQueue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.dismiss {
                SVProgressHUD.showInfo(withStatus: "復元に成功しました")
            }
        }
        if purchasingProduct!.productIdentifier == "moe.nnsnodnb.NowPlaying.autoTweet" {
            completePuchaseAutoTweet()
        } else if purchasingProduct!.productIdentifier == "moe.nnsnodnb.NowPlaying.hideAdMob" {
            completePurchaseRemoveAdmob()
        }
        isProcess = false
        purchasingProduct = nil
    }

    func finishRestore(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {
        isProcess = false
        purchasingProduct = nil
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: "復元に失敗しました")
            SVProgressHUD.dismiss(withDelay: 0.3)
        }
    }
}
