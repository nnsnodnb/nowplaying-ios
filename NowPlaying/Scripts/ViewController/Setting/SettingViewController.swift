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

class SettingViewController: FormViewController {

    private let keychain = Keychain(service: keychainServiceKey)

    private var isProcess = false
    private var isTwitterLogin = false
    private var isMastodonLogin = false
    private var productRequest: SKProductsRequest?
    private var products = [SKProduct]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

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
        isMastodonLogin = UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonLogin.rawValue)
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
            $0.value = UserDefaults.standard.bool(forKey: UserDefaultsKey.isWithImage.rawValue)
        }.onChange({ (row) in
            UserDefaults.standard.set(row.value!, forKey: UserDefaultsKey.isWithImage.rawValue)
            UserDefaults.standard.synchronize()
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "twitter_with_artwork",
                "value": row.value!]
            )
        })
        <<< ButtonRow() {
            $0.title = "自動ツイートを購入"
            $0.tag = "auto_tweet_purchase"
            $0.hidden = Condition(booleanLiteral: UserDefaults.standard.bool(forKey: UserDefaultsKey.isAutoTweetPurchase.rawValue))
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ [unowned self] (cell, row) in
            if self.isProcess {
                SVProgressHUD.showInfo(withStatus: "処理中です")
                return
            }
            guard let product = self.products.first else {
                SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
                return
            }
            self.isProcess = true
            PaymentManager.shared.buyProduct(product)
        })
        <<< SwitchRow() {
            $0.title = "自動ツイート"
            $0.value = UserDefaults.standard.bool(forKey: UserDefaultsKey.isAutoTweet.rawValue)
            $0.tag = "auto_tweet_switch"
            $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
            }
        }.onChange({ (row) in
            UserDefaults.standard.set(row.value!, forKey: UserDefaultsKey.isAutoTweet.rawValue)
            UserDefaults.standard.synchronize()
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "twitter_auto_tweet",
                "value": row.value!]
            )
            if !row.value! || UserDefaults.standard.bool(forKey: UserDefaultsKey.isShowAutoTweetAlert.rawValue) {
                return
            }
            let alert = UIAlertController(title: nil, message: "起動中のみ自動的にツイートされます", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true) {
                    UserDefaults.standard.set(true, forKey: UserDefaultsKey.isShowAutoTweetAlert.rawValue)
                    UserDefaults.standard.synchronize()
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
            $0.value = UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)
            $0.tag = "mastodon_host"
        }.cellSetup({ [unowned self] (cell, row) in
            cell.textField.keyboardType = .URL
            row.baseCell.isUserInteractionEnabled = !self.isMastodonLogin
        }).onChange({ (row) in
            guard let value = row.value else {
                return
            }
            UserDefaults.standard.set(value, forKey: UserDefaultsKey.mastodonHostname.rawValue)
            UserDefaults.standard.synchronize()
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
            row.deselect()
            if !self.isMastodonLogin {
                let baseUrl = UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)!
                guard URL(string: baseUrl + "/api/v1/apps") != nil else {
                    self.showMastodonError()
                    return
                }
                SVProgressHUD.show()
                /* アプリの登録 */
                MastodonClient.shared.register(handler: { (responseJson, error) in
                    if error != nil {
                        self.showMastodonError()
                        SVProgressHUD.dismiss()
                        return
                    }
                    let clientID = responseJson!["client_id"] as! String
                    let clientSecret = responseJson!["client_secret"] as! String

                    self.keychain[KeychainKey.mastodonClientID.rawValue] = clientID
                    self.keychain[KeychainKey.mastodonClientSecret.rawValue] = clientSecret

                    /* GUIログイン */
                    let webViewController = WebViewController()
                    webViewController.url = URL(string: baseUrl + "/oauth/authorize?client_id=\(clientID)&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=write")!
                    webViewController.handler = { accessToken, error in
                        if error != nil {
                            self.showMastodonError()
                            return
                        }
                        self.isMastodonLogin = true
                        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isMastodonLogin.rawValue)
                        UserDefaults.standard.synchronize()
                        Analytics.logEvent("tap", parameters: [
                            "type": "action",
                            "button": "mastodon_login"]
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            SVProgressHUD.showSuccess(withStatus: "ログインしました")
                            SVProgressHUD.dismiss(withDelay: 0.5)
                            cell.textLabel?.text = "ログアウト"
                            let textRow = self.form.rowBy(tag: "mastodon_host") as! TextRow
                            textRow.baseCell.isUserInteractionEnabled = false
                        }
                    }
                    let navi = UINavigationController(rootViewController: webViewController)
                    DispatchQueue.main.async {
                        self.present(navi, animated: true) {
                            SVProgressHUD.dismiss()
                        }
                    }
                })
            } else {
                AuthManager.shared.mastodonLogout()
                self.isMastodonLogin = false
                UserDefaults.standard.set(false, forKey: UserDefaultsKey.isMastodonLogin.rawValue)
                UserDefaults.standard.synchronize()
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
            $0.value = UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonWithImage.rawValue)
        }.onChange({ (row) in
            UserDefaults.standard.set(row.value!, forKey: UserDefaultsKey.isMastodonWithImage.rawValue)
            UserDefaults.standard.synchronize()
            Analytics.logEvent("change", parameters: [
                "type": "action",
                "button": "mastodon_with_artwork",
                "value": row.value!]
            )
        })
        <<< SwitchRow() {
            $0.title = "自動トゥート"
            $0.value = UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonAutoToot.rawValue)
        }.onChange({ (row) in
            UserDefaults.standard.set(row.value!, forKey: UserDefaultsKey.isMastodonAutoToot.rawValue)
            UserDefaults.standard.synchronize()
            if !row.value! || UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonShowAutoTweetAlert.rawValue) {
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
                    UserDefaults.standard.set(true, forKey: UserDefaultsKey.isMastodonShowAutoTweetAlert.rawValue)
                    UserDefaults.standard.synchronize()
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
            $0.title = "レビューする"
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ [unowned self] (cell, row) in
            Analytics.logEvent("tap", parameters: [
                "type": "action",
                "button": "appstore_review",
                "os": UIDevice.current.systemVersion]
            )
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                if let url = URL(string: "https://itunes.apple.com/us/app/itunes-u/id1289764391?action=write-review") {
                    let alert = UIAlertController(title: nil, message: "AppStoreを起動します", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        UIApplication.shared.openURL(url)
                    }
                    alert.addAction(okAction)
                    alert.preferredAction = okAction
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
    }

    private func showMastodonError() {
        let alert = UIAlertController(title: "エラー", message: "Mastodonのホストネームを確認してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupProducts() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.isAutoTweetPurchase.rawValue) {
            return
        }
        PaymentManager.shared.delegate = self
        let productIds = Set(arrayLiteral: "moe.nnsnodnb.NowPlaying.autoTweet")
        SVProgressHUD.show()
        productRequest = PaymentManager.shared.startProductRequest(productIds)
    }

    // MARK: - UIBarButtonItem target

    @objc private func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PaymentManagerProtocol

extension SettingViewController: PaymentManagerProtocol {

    func finish(request: SKProductsRequest, products: [SKProduct]) {
        self.products = products
        SVProgressHUD.dismiss()
    }

    func finish(request: SKRequest, didFailWithError: Error) {
        SVProgressHUD.showError(withStatus: "通信エラーが発生しました")
    }

    func finish(success paymentTransaction: SKPaymentTransaction) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            SVProgressHUD.show()
            guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
                return
            }
            do {
                let receiptData = try Data(contentsOf: receiptUrl, options: .uncached)
                let requestContents = [
                    "receipt-data": receiptData.base64EncodedString()
                ]
                let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: [])
                let verifyUrl: String!
                #if DEBUG
                    verifyUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
                #else
                    verifyUrl = "https://buy.itunes.apple.com/verifyReceipt"
                #endif
                let storeUrl = URL(string: verifyUrl)!
                var storeRequest = URLRequest(url: storeUrl)
                storeRequest.httpMethod = "POST"
                storeRequest.httpBody = requestData

                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: storeRequest) { [weak self] (data, response, error) in
                    guard let data = data else {
                        return
                    }
                    do {
                        guard let jsonResponse = try JSONSerialization.jsonObject(with: data,
                                                                                  options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as? [String: Any],
                            let status = jsonResponse["status"] as? Int,
                            status == 0 else { return }
                        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAutoTweetPurchase.rawValue)
                        UserDefaults.standard.synchronize()
                        DispatchQueue.main.async { [weak self] in
                            SVProgressHUD.dismiss()
                            guard let wself = self else { return }
                            wself.isProcess = false
                            let purchaseButtonRow: ButtonRow = wself.form.rowBy(tag: "auto_tweet_purchase")!
                            let autoTweetSwitchRow: SwitchRow = wself.form.rowBy(tag: "auto_tweet_switch")!
                            purchaseButtonRow.hidden = Condition(booleanLiteral: true)
                            purchaseButtonRow.evaluateHidden()
                            autoTweetSwitchRow.evaluateHidden()
                        }
                    } catch {
                        SVProgressHUD.showError(withStatus: "検証に失敗しました")
                    }
                }
                task.resume()
            } catch {
                self.isProcess = false
                fatalError()
            }
        }
    }

    func finishPayment(failed paymentTransaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: "購入に失敗しました")
        }
    }

    func finishRestore(queue: SKPaymentQueue) {

    }

    func finishRestore(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {

    }
}
