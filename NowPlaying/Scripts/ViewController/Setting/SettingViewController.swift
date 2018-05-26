//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/22.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD
import TwitterKit
import StoreKit
import SafariServices
import KeychainAccess
import FirebaseAnalytics
import ExtensionCollection

class SettingViewController: FormViewController {

    private let keychain = Keychain(service: keychainServiceKey)

    private var safari: SFSafariViewController!
    private var isProcess = false
    private var isTwitterLogin = false
    private var isMastodonLogin = false
    private var productRequest: SKProductsRequest?
    private var products = [SKProduct]()
    private var purchasingProduct: SKProduct?
    private var mastodonLoginButtonRowCell: ButtonRow.Cell?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupNavigationbar()
        setupIsLogin()
        setupProducts()
        twitterForm()
        mastodonForm()
        aboutForm()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: receiveSafariNotificationName, object: nil)
    }

    // MARK: - Private method

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSafariNotification(_:)),
                                               name: receiveSafariNotificationName,
                                               object: nil)
    }

    private func setupNavigationbar() {
        guard navigationController != nil else {
            return
        }
        title = "設定"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onTapCloseButton(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }

    private func setupIsLogin() {
        isTwitterLogin = Twitter.sharedInstance().sessionStore.session() != nil
        isMastodonLogin = UserDefaults.bool(forKey: .isMastodonLogin)
    }

    private func twitterForm() {
        form
        +++ Section("Twitter") {
            $0.tag = "twitter_section"
        }
        <<< ButtonRow() { [unowned self] in
            $0.title = !self.isTwitterLogin ? "ログイン" : "ログアウト"
            $0.tag = "twitter_login"
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ (cell, row) in
            row.deselect()
            SVProgressHUD.show()
            if self.isTwitterLogin {
                AuthManager.shared.logout {
                    SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    self.isTwitterLogin = !self.isTwitterLogin
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
                    self.isTwitterLogin = !self.isTwitterLogin
                    DispatchQueue.main.async {
                        cell.textLabel?.text = "ログアウト"
                    }
                    Analytics.logEvent("tap", parameters: [
                        "type": "action",
                        "button": "twitter_login"]
                    )
                }
            }
        })
        <<< SwitchRow() {
            $0.title = "アートワークを添付"
            $0.value = UserDefaults.bool(forKey: .isWithImage)
        }.onChange({ (row) in
            UserDefaults.set(row.value!, forKey: .isWithImage)
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "twitter_with_artwork",
                "value": row.value!]
            )
        })
        <<< ButtonRow() {
            $0.title = "自動ツイートを購入"
            $0.tag = "auto_tweet_purchase"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isAutoTweetPurchase))
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ [unowned self] (cell, row) in
            if JailbreakChecker.isJailbreak {
                let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                DispatchQueue.main.async { [unowned self] in
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            if self.isProcess {
                SVProgressHUD.showInfo(withStatus: "処理中です")
                return
            }
            guard let product = self.products.first else {
                SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
                return
            }
            self.isProcess = true
            self.showSelectPurchaseType(product: product)

        })
        <<< SwitchRow() {
            $0.title = "自動ツイート"
            $0.value = UserDefaults.bool(forKey: .isAutoTweet)
            $0.tag = "auto_tweet_switch"
            $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
            }
        }.onChange({ (row) in
            UserDefaults.set(row.value!, forKey: .isAutoTweet)
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "twitter_auto_tweet",
                "value": row.value!]
            )
            if !row.value! || UserDefaults.bool(forKey: .isShowAutoTweetAlert) {
                return
            }
            let alert = UIAlertController(title: nil, message: "起動中のみ自動的にツイートされます", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true) {
                    UserDefaults.set(true, forKey: .isShowAutoTweetAlert)
                }
            }
        })
    }

    private func mastodonForm() {
        form
        +++ Section("Mastodon")
        <<< TextRow() {
            $0.title = "ホストネーム"
            $0.placeholder = "https://mstdn.jp"
            $0.value = UserDefaults.string(forKey: .mastodonHostname)
            $0.tag = "mastodon_host"
        }.cellSetup({ [unowned self] (cell, row) in
            cell.textField.keyboardType = .URL
            row.baseCell.isUserInteractionEnabled = !self.isMastodonLogin
        }).onChange({ (row) in
            guard let value = row.value else {
                return
            }
            UserDefaults.set(value, forKey: .mastodonHostname)
        })
        <<< ButtonRow() {
            $0.title = !isMastodonLogin ? "ログイン" : "ログアウト"
            $0.tag = "mastodon_login"
            $0.hidden = Condition.function(["mastodon_host"], { form in
                return (form.rowBy(tag: "mastodon_host") as! TextRow).value == nil
            })
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ [unowned self] (cell, row) in
            self.mastodonLoginButtonRowCell = cell
            row.deselect()
            if let baseUrl = UserDefaults.string(forKey: .mastodonHostname), !self.isMastodonLogin {
                MastodonRequest.Register().send { [weak self] (result) in
                    switch result {
                    case .success(let response):
                        guard let wself = self, let body = response.body, let clientID = body["client_id"] as? String,
                            let clientSecret = body["client_secret"] as? String else {
                            self?.showMastodonError()
                            return
                        }
                        UserDefaults.set(clientID, forKey: .mastodonClientID)
                        UserDefaults.set(clientSecret, forKey: .mastodonClientSecret)
                        let url = URL(string: baseUrl + "/oauth/authorize?client_id=\(clientID)&response_type=code&redirect_uri=nowplaying-ios-nnsnodnb://oauth_mastodon&scope=write")!
                        wself.safari = SFSafariViewController(url: url)
                        wself.present(wself.safari, animated: true, completion: nil)
                    case .failure:
                        self?.showMastodonError()
                    }
                }
            } else {
                AuthManager.shared.mastodonLogout()
                self.isMastodonLogin = false
                UserDefaults.set(false, forKey: .isMastodonLogin)
                Analytics.logEvent("tap", parameters: [
                    "type": "action",
                    "button": "mastodon_logout"]
                )
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    cell.textLabel?.text = "ログイン"
                    let textRow = self.form.rowBy(tag: "mastodon_host") as! TextRow
                    textRow.baseCell.isUserInteractionEnabled = true
                }
            }
        })
        <<< SwitchRow() {
            $0.title = "アートワークを添付"
            $0.value = UserDefaults.bool(forKey: .isMastodonWithImage)
        }.onChange({ (row) in
            UserDefaults.set(row.value!, forKey: .isMastodonWithImage)
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "mastodon_with_artwork",
                "value": row.value!]
            )
        })
        <<< SwitchRow() {
            $0.title = "自動トゥート"
            $0.value = UserDefaults.bool(forKey: .isMastodonAutoToot)
        }.onChange({ (row) in
            UserDefaults.set(row.value!, forKey: .isMastodonAutoToot)
            if !row.value! || UserDefaults.bool(forKey: .isMastodonShowAutoTweetAlert) {
                return
            }
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "mastodon_auto_tweet",
                "value": row.value!]
            )
            let alert = UIAlertController(title: nil, message: "起動中のみ自動的にトゥートされます", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true) {
                    UserDefaults.set(true, forKey: .isMastodonShowAutoTweetAlert)
                }
            }
        })
    }

    private func aboutForm() {
        form
        +++ Section("アプリについて")
        <<< ButtonRow() {
            $0.title = "開発者(Twitter)"
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ [unowned self] (cell, row) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://twitter.com/nnsnodnb")!)
            Analytics.logEvent("tap", parameters: [
                "type": "action",
                "button": "developer_twitter"]
            )
            DispatchQueue.main.async {
                self.navigationController?.present(safariViewController, animated: true, completion: nil)
            }
        })
        <<< ButtonRow() {
            $0.title = "ソースコード(GitHub)"
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ (cell, row) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!)
            Analytics.logEvent("tap", parameters: [
                "type": "action",
                "button": "github_respository"]
            )
            DispatchQueue.main.async {
                self.navigationController?.present(safariViewController, animated: true, completion: nil)
            }
        })
        <<< ButtonRow() {
            $0.title = "バグ報告"
        }.cellUpdate { (cell, _) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://goo.gl/forms/Ve9hPalUJD3DQW5y2")!)
            DispatchQueue.main.async {
                self.navigationController?.present(safariViewController, animated: true, completion: nil)
            }
        }
        <<< ButtonRow() {
            $0.title = "アプリ内広告削除(有料)"
            $0.tag = "remove_admob"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isPurchasedRemoveAdMob))
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ (cell, row) in
            if JailbreakChecker.isJailbreak {
                let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                DispatchQueue.main.async { [unowned self] in
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            if self.isProcess {
                SVProgressHUD.showInfo(withStatus: "処理中です")
                return
            }
            guard let product = self.products.last else {
                SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
                return
            }
            self.isProcess = true
            self.showSelectPurchaseType(product: product)
        })
        <<< ButtonRow() {
            $0.title = "レビューする"
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ (cell, row) in
            Analytics.logEvent("tap", parameters: [
                "type": "action",
                "button": "appstore_review",
                "os": UIDevice.current.systemVersion]
            )
            SKStoreReviewController.requestReview()
        })
    }

    private func showMastodonError() {
        let alert = UIAlertController(title: "エラー", message: "Mastodonのホストネームを確認してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

    // MARK: - Notification target

    @objc private func receiveSafariNotification(_ notification: Notification) {
        guard let url = notification.object as? URL, let queryString = url.query else { return }
        let query = QueryParser.queryDictionary(query: queryString)
        guard let code = query["code"] as? String else { return }
        MastodonRequest.GetToken(code: code).send { [weak self] (result) in
            guard let wself = self else { return }
            switch result {
            case .success(let response):
                guard let body = response.body, let accessToken = body["access_token"] as? String else {
                    return
                }
                wself.keychain[KeychainKey.mastodonAccessToken.rawValue] = accessToken
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "ログインしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    wself.isMastodonLogin = true
                    UserDefaults.set(true, forKey: .isMastodonLogin)
                    wself.mastodonLoginButtonRowCell?.textLabel?.text = "ログアウト"
                    let textRow = wself.form.rowBy(tag: "mastodon_host") as! TextRow
                    textRow.baseCell.isUserInteractionEnabled = false
                }
            case .failure:
                break
            }
            DispatchQueue.main.async {
                wself.dismiss(animated: true, completion: nil)
            }
        }
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
