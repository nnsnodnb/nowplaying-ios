//
//  MastodonSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Eureka
import FirebaseAnalytics
import KeychainAccess
import SafariServices
import SVProgressHUD
import UIKit

final class MastodonSettingViewController: FormViewController {

    private let keychain = Keychain(service: keychainServiceKey)

    private var isMastodonLogin = false
    private var mastodonLoginButtonRowCell: ButtonRow.Cell?
    private var safari: SFSafariViewController!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        title = "Mastodon設定"
        isMastodonLogin = UserDefaults.bool(forKey: .isMastodonLogin)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("Mastodon設定画面", screenClass: "MastodonSettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
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
    private func showMastodonError() {
        let alert = UIAlertController(title: "エラー", message: "Mastodonのホストネームを確認してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupForm() {
        form
            +++ Section("Mastodon")
            <<< TextRow { (row) in
                row.title = "ホストネーム"
                row.placeholder = "https://mstdn.jp"
                row.value = UserDefaults.string(forKey: .mastodonHostname)
                row.tag = "mastodon_host"
            }.cellSetup { [unowned self] (cell, row) in
                cell.textField.keyboardType = .URL
                row.baseCell.isUserInteractionEnabled = !self.isMastodonLogin
            }.onChange { (row) in
                guard let value = row.value else { return }
                UserDefaults.set(value, forKey: .mastodonHostname)
            }
            <<< NowPlayingButtonRow { (row) in
                row.title = !isMastodonLogin ? "ログイン" : "ログアウト"
                row.tag = "mastodon_login"
                row.hidden = Condition.function(["mastodon_host"]) { form in
                    return (form.rowBy(tag: "mastodon_host") as! TextRow).value == nil
                }
            }.onCellSelection { [unowned self] (cell, _) in
                self.mastodonLoginButtonRowCell = cell
                if let baseUrl = UserDefaults.string(forKey: .mastodonHostname), !self.isMastodonLogin {
                    MastodonRequest.Register().send { [weak self] (result) in
                        switch result {
                        case .success(let response):
                            guard let wself = self else { return }
                            guard let body = response.body, let clientID = body["client_id"] as? String,
                                let clientSecret = body["client_secret"] as? String else {
                                    wself.showMastodonError()
                                    return
                            }
                            UserDefaults.set(clientID, forKey: .mastodonClientID)
                            UserDefaults.set(clientSecret, forKey: .mastodonClientSecret)
                            let url = URL(string: baseUrl + "/oauth/authorize?client_id=\(clientID)&response_type=code&redirect_uri=nowplaying-ios-nnsnodnb://oauth_mastodon&scope=write")!
                            wself.safari = SFSafariViewController(url: url)
                            DispatchQueue.main.async {
                                wself.present(wself.safari, animated: true, completion: nil)
                            }
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
            }
            <<< SwitchRow { (row) in
                row.title = "アートワークを添付"
                row.value = UserDefaults.bool(forKey: .isMastodonWithImage)
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isMastodonWithImage)
                Analytics.logEvent("change", parameters: [
                    "type": "action",
                    "button": "mastodon_with_artwork",
                    "value": row.value!]
                )
            }
            <<< SwitchRow { (row) in
                row.title = "自動トゥート"
                row.value = UserDefaults.bool(forKey: .isMastodonAutoToot)
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isMastodonAutoToot)
                if !row.value! || UserDefaults.bool(forKey: .isMastodonShowAutoTweetAlert) {
                    return
                }
                Analytics.logEvent("change", parameters: [
                    "type": "action",
                    "button": "mastodon_auto_tweet",
                    "value": row.value!]
                )
                let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもツイートされますが、iOS上での制約のため長時間には対応できません。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true) {
                        UserDefaults.set(true, forKey: .isMastodonShowAutoTweetAlert)
                    }
                }
            }
    }
}

// MARK: - Notification target

extension MastodonSettingViewController {

    @objc private func receiveSafariNotification(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
        guard let query = (url as NSURL).uq_queryDictionary() else { return }
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
