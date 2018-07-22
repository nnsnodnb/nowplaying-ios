//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics
import DTTJailbreakDetection
import SVProgressHUD
import StoreKit

class TwitterSettingViewController: SNSSettingBaseViewController {

    private var isProces = false
    private var productRequest: SKProductsRequest?
    private var autoTweetProduct: SKProduct?

    // MARK: - Life cycle

    override func viewDidLoad() {
        title = "Twitter設定"
        screenName = "Twitter設定画面"
        viewControllerName = "TwitterSettingViewController"
        super.viewDidLoad()
        setupProducts()
    }

    // MARK: - Private method

    private func showSelectPurchaseType(product: SKProduct) {
        let alert = UIAlertController(title: "復元しますか？購入しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "復元", style: .default) { (_) in
            PaymentManager.shared.startRestore()
        })
        let newPurchaseAction = UIAlertAction(title: "購入", style: .default) { (_) in
            PaymentManager.shared.buyProduct(product)
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
        PaymentManager.shared.delegate = self
        let productId = Set(arrayLiteral: "moe.nnsnodnb.NowPlaying.autoTweet")
        SVProgressHUD.show()
        productRequest = PaymentManager.shared.startProductRequest(productId)
    }

    // MARK: - Override method

    override func setupForm() {
        form
            +++ Section("Twitter") {
                $0.tag = "twitter_section"
            }
            <<< ButtonRow() { (row) in
                row.title = !TwitterClient.shared.isLogin ? "ログイン" : "ログアウト"
                row.tag = "twitter_login"
            }.cellUpdate { (cell, _) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { (cell, _) in
                SVProgressHUD.show()
                if TwitterClient.shared.isLogin {
                    AuthManager.shared.logout {
                        SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログイン"
                        }
                        Analytics.logEvent("tap", parameters: [
                            "type": "action",
                            "button": "twitter_logout"]
                        )
                    }
                } else {
                    AuthManager.shared.login() {
                        SVProgressHUD.showSuccess(withStatus: "ログインしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログアウト"
                        }
                        Analytics.logEvent("tap", parameters: [
                            "type": "action",
                            "button": "twitter_login"]
                        )
                    }
                }
            }
            <<< SwitchRow() { (row) in
                row.title = "アートワークを添付"
                row.value = UserDefaults.bool(forKey: .isWithImage)
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isWithImage)
                Analytics.logEvent("change", parameters: [
                    "type": "action",
                    "button": "twitter_with_artwork",
                    "value": row.value!]
                )
            }
            <<< ButtonRow() { (row) in
                row.title = "自動ツイートを購入"
                row.tag = "auto_tweet_purchase"
                row.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isAutoTweetPurchase))
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [unowned self] (cell, row) in
                guard !DTTJailbreakDetection.isJailbroken() else {
                    let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    DispatchQueue.main.async { [unowned self] in
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                if self.isProces {
                    SVProgressHUD.showInfo(withStatus: "処理中です")
                    return
                }
                guard let product = self.autoTweetProduct else {
                    SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
                    return
                }
                self.isProces = true
                self.showSelectPurchaseType(product: product)
            }
            <<< SwitchRow() {
                $0.title = "自動ツイート"
                $0.value = UserDefaults.bool(forKey: .isAutoTweet)
                $0.tag = "auto_tweet_switch"
                $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                    return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
                }
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isAutoTweet)
                Analytics.logEvent("change", parameters: [
                    "type": "action",
                    "button": "twitter_auto_tweet",
                    "value": row.value!]
                )
                if !row.value! || UserDefaults.bool(forKey: .isShowAutoTweetAlert) {
                    return
                }
                let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもツイートされますが、iOS上での制約のため長時間には対応できません。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true) {
                        UserDefaults.set(true, forKey: .isShowAutoTweetAlert)
                    }
                }
            }
    }
}

// MARK: - PaymentManagerProtocol

extension TwitterSettingViewController: PaymentManagerProtocol {

    func finish(request: SKProductsRequest, products: [SKProduct]) {
        autoTweetProduct = products.first
    }

    func finish(request: SKRequest, didFailWithError: Error) {

    }

    func finish(success paymentTransaction: SKPaymentTransaction) {

    }

    func finishPayment(failed paymentTransaction: SKPaymentTransaction) {

    }

    func finishRestore(queue: SKPaymentQueue) {

    }

    func finishRestore(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {

    }
}
