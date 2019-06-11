//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import FirebaseAnalytics
import Foundation
import RxCocoa
import RxSwift
import SVProgressHUD

// MARK: - TwitterSettingViewModelOutput

protocol TwitterSettingViewModelOutput {

    var presentViewController: Driver<UIViewController> { get }
    var startInAppPurchase: Observable<Void> { get }
}

// MARK: - TwitterSettingViewModelType

protocol TwitterSettingViewModelType {

    var outputs: TwitterSettingViewModelOutput { get }
    var form: Form { get }

    func buyProduct(_ product: PaymentManager.Product)
    func restore()
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {

    let form: Form

    var outputs: TwitterSettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _presentViewController = PublishRelay<UIViewController>()
    private let _startInAppPurchase = PublishRelay<Void>()

    init() {
        form = Form()

        configureCells()
    }

    func buyProduct(_ product: PaymentManager.Product) {
        PaymentManager.shared.buyProduct(product)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .purchased:
                    SVProgressHUD.showSuccess(withStatus: "購入が完了しました！")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    product.finishPurchased()
                    self?.changeStateAutoTweet()
                case .purchasing:
                    SVProgressHUD.show(withStatus: "購入処理中...")
                }
            }, onError: { (_) in
                SVProgressHUD.showError(withStatus: "購入が失敗しました")
                SVProgressHUD.dismiss(withDelay: 0.5)
            })
            .disposed(by: disposeBag)
    }

    func restore() {
        PaymentManager.shared.restore()
            .subscribe(onNext: { [weak self] (products) in
                products.forEach {
                    $0.finishPurchased()
                    switch $0 {
                    case .hideAdmob:
                        // SettingViewModel に通知を送る
                        NotificationCenter.default.post(name: .purchasedHideAdMobNotification, object: nil)
                    case .autoTweet:
                        self?.changeStateAutoTweet()
                    }
                }
                SVProgressHUD.showSuccess(withStatus: "復元が完了しました")
                SVProgressHUD.dismiss(withDelay: 0.5)
            }, onError: { (_) in
                SVProgressHUD.showError(withStatus: "復元に失敗しました")
                SVProgressHUD.dismiss(withDelay: 0.5)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method

extension TwitterSettingViewModel {

    private func configureCells() {
        form
            +++ Section("Twitter") {
                $0.tag = "twitter_section"
            }

            <<< NowPlayingButtonRow {
                $0.title = "ログイン"
                $0.tag = "twitter_login"
                $0.hidden = Condition(booleanLiteral: TwitterClient.shared.isLogin)
            }.onCellSelection { [weak self] (_, _) in
                SVProgressHUD.show()
                AuthManager.shared.login { [weak self] (error) in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        return
                    }
                    SVProgressHUD.showSuccess(withStatus: "ログインしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    DispatchQueue.main.async {
                        self?.changeTwitterLogState(didLogin: true)
                    }
                }
                Analytics.TwitterSetting.login()
            }

            <<< NowPlayingButtonRow {
                $0.title = "ログアウト"
                $0.tag = "twitter_logout"
                $0.hidden = Condition(booleanLiteral: !TwitterClient.shared.isLogin)
            }.onCellSelection { [weak self] (_, _) in
                SVProgressHUD.show()
                AuthManager.shared.logout {
                    SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                    DispatchQueue.main.async {
                        self?.changeTwitterLogState(didLogin: false)
                    }
                }
                Analytics.TwitterSetting.logout()
            }

            <<< SwitchRow {
                $0.title = "アートワークを添付"
                $0.value = UserDefaults.bool(forKey: .isWithImage)
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isWithImage)
                Analytics.TwitterSetting.changeWithArtwork(row.value!)
            }

            <<< NowPlayingButtonRow {
                $0.title = "自動ツイートを購入"
                $0.tag = "auto_tweet_purchase"
                $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isAutoTweetPurchase))
            }.onCellSelection { [weak self] (_, _) in
                guard !DTTJailbreakDetection.isJailbroken() else {
                    let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self?._presentViewController.accept(alert)
                    return
                }
                self?._startInAppPurchase.accept(())
            }

            <<< SwitchRow {
                $0.title = "自動ツイート"
                $0.value = UserDefaults.bool(forKey: .isAutoTweet)
                $0.tag = "auto_tweet_switch"
                $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                    return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
                }
            }.onChange { [weak self] in
                UserDefaults.set($0.value!, forKey: .isAutoTweet)
                Analytics.TwitterSetting.changeAutoTweet($0.value!)
                if !$0.value! || UserDefaults.bool(forKey: .isShowAutoTweetAlert) { return }
                let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもツイートされますが、iOS上での制約のため長時間には対応できません。",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?._presentViewController.accept(alert)
                UserDefaults.set(true, forKey: .isShowAutoTweetAlert)
        }
    }

    private func changeStateAutoTweet() {
        if !UserDefaults.bool(forKey: .isAutoTweetPurchase) { return }
        guard let purchaseButtonRow: NowPlayingButtonRow = form.rowBy(tag: "auto_tweet_purchase"),
            let autoTweetSwitchRow: SwitchRow = form.rowBy(tag: "auto_tweet_switch") else { return }
        purchaseButtonRow.hidden = Condition(booleanLiteral: true)
        autoTweetSwitchRow.hidden = Condition(booleanLiteral: false)
        purchaseButtonRow.evaluateHidden()
        autoTweetSwitchRow.evaluateHidden()
    }

    private func changeTwitterLogState(didLogin: Bool) {
        if TwitterClient.shared.isLogin != didLogin { return }
        guard let loginRow: NowPlayingButtonRow = form.rowBy(tag: "twitter_login"),
            let logoutRow: NowPlayingButtonRow = form.rowBy(tag: "twitter_logout") else { return }
        loginRow.hidden = Condition(booleanLiteral: didLogin)
        logoutRow.hidden = Condition(booleanLiteral: !didLogin)
        loginRow.evaluateHidden()
        logoutRow.evaluateHidden()
    }
}

extension TwitterSettingViewModel: TwitterSettingViewModelOutput {

    var presentViewController: SharedSequence<DriverSharingStrategy, UIViewController> {
        return _presentViewController.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var startInAppPurchase: Observable<Void> {
        return _startInAppPurchase.observeOn(MainScheduler.instance).asObservable()
    }
}