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

struct MastodonSettingViewModelInput {

    let viewController: UIViewController
}

// MARK: - MastodonSettingViewModelOutput

protocol MastodonSettingViewModelOutput {

    var error: Observable<Void> { get }
}

// MARK: - MastodonSettingViewModelType

protocol MastodonSettingViewModelType {

    var outputs: MastodonSettingViewModelOutput { get }
    var form: Form { get }

    init(inputs: MastodonSettingViewModelInput)
}

final class MastodonSettingViewModel: MastodonSettingViewModelType {

    let form: Form
    let error: Observable<Void>

    var outputs: MastodonSettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let inputs: MastodonSettingViewModelInput
    private let keychain = Keychain.nowPlaying
    private let _error = PublishRelay<Void>()

    private var isMastodonLogin: Bool {
        return UserDefaults.bool(forKey: .isMastodonLogin)
    }
    private var session: SFAuthenticationSession?

    init(inputs: MastodonSettingViewModelInput) {
        self.inputs = inputs
        form = Form()
        error = _error.observeOn(MainScheduler.instance).asObservable()

        configureCells()

        UserDefaults.standard.rx
            .observe(String.self, UserDefaultsKey.mastodonHostname.rawValue)
            .compactMap { $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let wself = self,
                    let domainRow = wself.form.rowBy(tag: "mastodon_domain") as? MastodonSettingDomainRow else { return }
                domainRow.value = $0
                domainRow.updateCell()
            })
            .disposed(by: disposeBag)
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
                <<< configureWith()
                <<< configureWithImageType()
                <<< configureAutoToot()

            +++ Section("投稿フォーマット", configureHeaderForTootFormat())
                <<< configureTootFormat()
                <<< configureFormatReset()
    }

    private func configureDomain() -> MastodonSettingDomainRow {
        return MastodonSettingDomainRow {
            $0.tag = "mastodon_domain"
            $0.value = UserDefaults.string(forKey: .mastodonHostname)
        }.onCellSelection { [unowned self] (_, row) in
            if UserDefaults.bool(forKey: .isMastodonLogin) {
                let alert = UIAlertController(title: "すでにログインされています", message: "ドメインを変更するには先にログアウトをしてください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
                self.inputs.viewController.present(alert, animated: true) {
                    row.deselect(animated: true)
                }
                return
            }
            let viewController = SearchMastodonTableViewController()
            self.inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func configureLogin() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "ログイン"
            $0.tag = "mastodon_login"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isMastodonLogin))
        }.onCellSelection { [unowned self] (_, _) in
            guard let domainRow = self.form.rowBy(tag: "mastodon_domain") as? MastodonSettingDomainRow,
                let hostname = domainRow.value, !self.isMastodonLogin else { return }
            SVProgressHUD.show()
            Session.shared.rx.response(MastodonAppRequeset(hostname: hostname))
                .subscribe(onSuccess: { [weak self] (response) in
                    UserDefaults.set(response.clientID, forKey: .mastodonClientID)
                    UserDefaults.set(response.clientSecret, forKey: .mastodonClientSecret)
                    let url = URL(string: "https://\(hostname)/oauth/authorize")!
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
                }, onError: { [weak self] (_) in
                    SVProgressHUD.dismiss()
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

    private func configureWith() -> SwitchRow {
        return SwitchRow {
            $0.title = "画像を添付"
            $0.value = UserDefaults.bool(forKey: .isMastodonWithImage)
        }.onChange {
            UserDefaults.set($0.value!, forKey: .isMastodonWithImage)
            Analytics.MastodonSetting.changeWithArtwork($0.value!)
        }
    }

    private func configureWithImageType() -> ActionSheetRow<String> {
        return ActionSheetRow<String> {
            $0.title = "投稿時の画像"
            $0.options = ["アートワークのみ", "再生画面のスクリーンショット"]
            $0.value = UserDefaults.string(forKey: .tootWithImageType)!
        }.onChange {
            guard let value = $0.value, let type = WithImageType(rawValue: value) else { return }
            UserDefaults.set(type.rawValue, forKey: .tootWithImageType)
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
            self.inputs.viewController.present(alert, animated: true) {
                UserDefaults.set(true, forKey: .isMastodonShowAutoTweetAlert)
            }
        }
    }

    private func configureHeaderForTootFormat() -> (Section) -> Void {
        return {
            let postFormatHelpView = R.nib.postFormatHelpView
            $0.footer = HeaderFooterView<PostFormatHelpView>(.nibFile(name: postFormatHelpView.name,
                                                                      bundle: postFormatHelpView.bundle))
        }
    }

    private func configureTootFormat() -> TextAreaRow {
        return TextAreaRow {
            $0.placeholder = "トゥートフォーマット"
            $0.tag = "toot_format"
            $0.value = UserDefaults.string(forKey: .tootFormat)
        }.onChange { (row) in
            guard let value = row.value, !value.isEmpty else { return }
            UserDefaults.set(value, forKey: .tootFormat)
        }
    }

    private func configureFormatReset() -> ButtonRow {
        return ButtonRow {
            $0.title = "リセットする"
        }.onCellSelection { [unowned self] (_, _) in
            let alert = UIAlertController(title: "投稿フォーマットをリセットします", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "リセット", style: .destructive) { [unowned self] (_) in
                guard let tweetFormatRow: TextAreaRow = self.form.rowBy(tag: "toot_format") else { return }
                DispatchQueue.main.async {
                    tweetFormatRow.baseValue = defaultPostFormat
                    tweetFormatRow.updateCell()
                }
            })
            self.inputs.viewController.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Private method (Utilities)

extension MastodonSettingViewModel {

    private func challengeAuthenticationSession(with url: URL) {
        session = SFAuthenticationSession(url: url, callbackURLScheme: "nowplaying-ios-nnsnodnb") { [weak self] (url, _) in
            defer { self?.session = nil }
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
            let domainRow = form.rowBy(tag: "mastodon_domain") as? MastodonSettingDomainRow,
            let hostname = domainRow.value else { return }
        Session.shared.rx.response(MastodonGetTokenRequest(hostname: hostname, code: code))
            .subscribe(onSuccess: { [weak self] (response) in
                self?.keychain[.mastodonAccessToken] = response.accessToken
                SVProgressHUD.showSuccess(withStatus: "ログインしました")
                SVProgressHUD.dismiss(withDelay: 0.5)
                UserDefaults.set(true, forKey: .isMastodonLogin)
                self?.changeMastodonLogState(didLogin: true)
            }, onError: { [weak self] (_) in
                self?._error.accept(())
            })
            .disposed(by: self.disposeBag)
    }

    private func changeMastodonLogState(didLogin: Bool) {
        if UserDefaults.bool(forKey: .isMastodonLogin) != didLogin { return }
        guard let loginRow = form.rowBy(tag: "mastodon_login"),
            let logoutRow = form.rowBy(tag: "mastodon_logout") else { return }
        loginRow.hidden = Condition(booleanLiteral: didLogin)
        logoutRow.hidden = Condition(booleanLiteral: !didLogin)
        loginRow.evaluateHidden()
        logoutRow.evaluateHidden()
    }
}

// MARK: - MastodonSettingViewModelOutput

extension MastodonSettingViewModel: MastodonSettingViewModelOutput {}
