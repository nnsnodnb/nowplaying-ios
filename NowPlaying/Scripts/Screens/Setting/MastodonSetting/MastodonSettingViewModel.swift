//
//  MastodonSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Eureka
import FirebaseAnalytics
import Foundation
import KeychainAccess
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import NSURL_QueryDictionary

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
    private var session: SFAuthenticationSession?

    init() {
        form = Form()
        error = _error.observeOn(MainScheduler.instance).asObservable()

        configureCells()
    }
}

// MARK: - Private method (Form)

extension MastodonSettingViewModel {

    private func configureCells() {
        form
            +++ Section("Mastodon")
                <<< configureDomain()
                <<< configureLogin()
                <<< configureLogout()
                <<< configureArtwork()
                <<< configureAutoToot()
    }

    private func configureDomain() -> TextRow {
        return TextRow {
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
    }

    private func configureLogin() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "ログイン"
            $0.tag = "mastodon_login"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isMastodonLogin))
        }.onCellSelection { [unowned self] (_, _) in
            guard let textRow = self.form.rowBy(tag: "mastodon_host") as? TextRow,
                let hostname = textRow.value, !self.isMastodonLogin else { return }
            SVProgressHUD.show()
            Session.shared.rx.response(MastodonAppRequeset(hostname: hostname))
                .subscribe(onSuccess: { [weak self] (response) in
                    UserDefaults.set(response.clientID, forKey: .mastodonClientID)
                    UserDefaults.set(response.clientSecret, forKey: .mastodonClientSecret)
                    let url = URL(string: "\(hostname)/oauth/authorize")!
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: url.baseURL != nil)
                    components?.queryItems = [
                        URLQueryItem(name: "client_id", value: response.clientID),
                        URLQueryItem(name: "response_type", value: "code"),
                        URLQueryItem(name: "redirect_uri", value: "nowplaying-ios-nnsnodnb://oauth_mastodon"),
                        URLQueryItem(name: "scope", value: "write")
                    ]
                    SVProgressHUD.dismiss()
                    guard let authorizeURL = components?.url else {
                        self?._error.accept(())
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.challengeAuthenticationSession(with: authorizeURL)
                    }
                    }, onError: { [weak self] (error) in
                        SVProgressHUD.dismiss()
                        print(error)
                        self?._error.accept(())
                })
                .disposed(by: self.disposeBag)
            Analytics.MastodonSetting.login()
        }
    }

    private func configureLogout() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
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
    }

    private func configureArtwork() -> SwitchRow {
        return SwitchRow {
            $0.title = "アートワークを添付"
            $0.value = UserDefaults.bool(forKey: .isMastodonWithImage)
        }.onChange {
            UserDefaults.set($0.value!, forKey: .isMastodonWithImage)
            Analytics.MastodonSetting.changeWithArtwork($0.value!)
        }
    }

    private func configureAutoToot() -> SwitchRow {
        return SwitchRow {
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
}

// MARK: - Private method (Utilities)

extension MastodonSettingViewModel {

    private func challengeAuthenticationSession(with url: URL) {
        session = SFAuthenticationSession(url: url, callbackURLScheme: "nowplaying-ios-nnsnodnb") { [weak self] (url, error) in
            defer { self?.session = nil }
            print(url?.absoluteString ?? "")
            print(error?.localizedDescription ?? "")
            guard let url = url else {
                self?._error.accept(())
                return
            }
            self?.loginProcessForSafariCallback(url: url)
        }
        session?.start()
    }

    private func loginProcessForSafariCallback(url: URL) {
        guard let query = (url as NSURL).uq_queryDictionary(), let code = query["code"] as? String,
            let textRow = form.rowBy(tag: "mastodon_host") as? TextRow, let hostname = textRow.value else { return }
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
