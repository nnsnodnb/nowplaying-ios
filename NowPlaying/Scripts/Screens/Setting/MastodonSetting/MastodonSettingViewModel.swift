//
//  MastodonSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Eureka
import FirebaseAnalytics
import Foundation
import KeychainAccess
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD

// MARK: - MastodonSettingViewModelOutput

protocol MastodonSettingViewModelOutput {

    var presentViewController: Driver<UIViewController> { get }
    var endLoginSession: Observable<Void> { get }
    var error: Observable<Void> { get }
}

// MARK: - MastodonSettingViewModelType

protocol MastodonSettingViewModelType {

    var outputs: MastodonSettingViewModelOutput { get }
    var form: Form { get }
}

final class MastodonSettingViewModel: MastodonSettingViewModelType {

    let form: Form
    let error: Observable<Void>

    var outputs: MastodonSettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let keychain = Keychain(service: keychainServiceKey)
    private let _presentViewController = PublishRelay<UIViewController>()
    private let _endLoginSession = PublishRelay<Void>()
    private let _error = PublishRelay<Void>()

    private var isMastodonLogin: Bool {
        return UserDefaults.bool(forKey: .isMastodonLogin)
    }

    init() {
        form = Form()
        error = _error.observeOn(MainScheduler.instance).asObservable()

        NotificationCenter.default.rx.notification(.receiveSafariNotificationName, object: nil)
            .subscribe(onNext: { [weak self] (notification) in
                guard let url = notification.object as? URL else { return }
                self?.loginProcessForSafariCallback(url: url)
            })
            .disposed(by: disposeBag)

        configureCells()
    }
}

// MARK: - Private method

extension MastodonSettingViewModel {

    private func configureCells() {
        form
            +++ Section("Mastodon")

            <<< TextRow {
                $0.title = "ドメイン"
                $0.placeholder = "https://mstdn.jp"
                $0.value = UserDefaults.string(forKey: .mastodonHostname)
                $0.tag = "mastodon_host"
            }.cellSetup { [unowned self] (cell, row) in
                cell.textField.keyboardType = .URL
                row.baseCell.isUserInteractionEnabled = !self.isMastodonLogin
            }.onChange {
                guard let value = $0.value else { return }
                UserDefaults.set(value, forKey: .mastodonHostname)
            }

            <<< NowPlayingButtonRow {
                $0.title = "ログイン"
                $0.tag = "mastodon_login"
                $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isMastodonLogin))
            }.onCellSelection { [unowned self] (_, _) in
                guard let textRow = self.form.rowBy(tag: "mastodon_host") as? TextRow,
                    let hostname = textRow.value, !self.isMastodonLogin else {
                    return
                }
                Session.shared.rx.response(MastodonAppRequeset(hostname: hostname))
                    .subscribe(onSuccess: { [weak self] (response) in
                        UserDefaults.set(response.clientID, forKey: .mastodonClientID)
                        UserDefaults.set(response.clientSecret, forKey: .mastodonClientSecret)
                        let url = URL(string: "\(hostname)/oauth/authorize?client_id=\(response.clientID)&response_type=code&redirect_uri=nowplaying-ios-nnsnodnb://oauth_mastodon&scope=write")!
                        let safari = SFSafariViewController(url: url)
                        self?._presentViewController.accept(safari)
                    }, onError: { [weak self] (error) in
                        print(error)
                        self?._error.accept(())
                    })
                    .disposed(by: self.disposeBag)
                Analytics.MastodonSetting.login()
            }

            <<< NowPlayingButtonRow {
                $0.title = "ログアウト"
                $0.tag = "mastodon_logout"
                $0.hidden = Condition(booleanLiteral: !UserDefaults.bool(forKey: .isMastodonLogin))
            }.onCellSelection { [weak self] (_, _) in
                AuthManager.shared.mastodonLogout()
                UserDefaults.set(false, forKey: .isMastodonLogin)
                Analytics.MastodonSetting.logout()
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    self?.changeMastodonLogState(didLogin: false)
                }
            }

            <<< SwitchRow {
                $0.title = "アートワークを添付"
                $0.value = UserDefaults.bool(forKey: .isMastodonWithImage)
            }.onChange {
                UserDefaults.set($0.value!, forKey: .isMastodonWithImage)
                Analytics.MastodonSetting.changeWithArtwork($0.value!)
            }

            <<< SwitchRow {
                $0.title = "自動トゥート"
                $0.value = UserDefaults.bool(forKey: .isMastodonAutoToot)
            }.onChange { [unowned self] in
                UserDefaults.set($0.value!, forKey: .isMastodonAutoToot)
                Analytics.MastodonSetting.changeAutoToot($0.value!)
                if !$0.value! || UserDefaults.bool(forKey: .isMastodonShowAutoTweetAlert) {
                    return
                }
                let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもトゥートされますが、iOS上での制約のため長時間には対応できません。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                UserDefaults.set(true, forKey: .isMastodonShowAutoTweetAlert)
                self._presentViewController.accept(alert)
        }
    }

    private func loginProcessForSafariCallback(url: URL) {
        guard let query = (url as NSURL).uq_queryDictionary(), let code = query["code"] as? String,
            let textRow = self.form.rowBy(tag: "mastodon_host") as? TextRow, let hostname = textRow.value else { return }
        Session.shared.rx.response(MastodonGetTokenRequest(hostname: hostname, code: code))
            .subscribe(onSuccess: { [weak self] (response) in
                self?.keychain[KeychainKey.mastodonAccessToken.rawValue] = response.accessToken
                SVProgressHUD.showSuccess(withStatus: "ログインしました")
                SVProgressHUD.dismiss(withDelay: 0.5)
                UserDefaults.set(true, forKey: .isMastodonLogin)
                self?.changeMastodonLogState(didLogin: true)
                self?._endLoginSession.accept(())
            }, onError: { [weak self] (error) in
                print(error)
                self?._error.accept(())
            })
            .disposed(by: self.disposeBag)
    }

    private func changeMastodonLogState(didLogin: Bool) {
        if UserDefaults.bool(forKey: .isMastodonLogin) != didLogin { return }
        guard let textRow = form.rowBy(tag: "mastodon_host") as? TextRow,
            let loginRow = form.rowBy(tag: "mastodon_login"),
            let logoutRow = form.rowBy(tag: "mastodon_logout") else { return }
        textRow.baseCell.isUserInteractionEnabled = !didLogin
        loginRow.hidden = Condition(booleanLiteral: didLogin)
        logoutRow.hidden = Condition(booleanLiteral: !didLogin)
        loginRow.evaluateHidden()
        logoutRow.evaluateHidden()
    }
}

// MARK: - MastodonSettingViewModelOutput

extension MastodonSettingViewModel: MastodonSettingViewModelOutput {

    var presentViewController: Driver<UIViewController> {
        return _presentViewController.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var endLoginSession: Observable<Void> {
        return _endLoginSession.observeOn(MainScheduler.instance).asObservable()
    }
}
