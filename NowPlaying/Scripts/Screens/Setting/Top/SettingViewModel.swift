//
//  SettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import Feeder
import FirebaseAnalytics
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import UIKit

enum SettingTransitionConfig {
    case twitter, mastodon, safari(URL), alert(AlertConfigurations)
}

// MARK: - SettingViewModelInput

protocol SettingViewModelInput {

    var buyProductTrigger: PublishRelay<PaymentManager.Product> { get }
    var restoreTrigger: PublishRelay<Void> { get }
}

// MARK: - SettingViewModelOutput

protocol SettingViewModelOutput {

    var startInAppPurchase: Observable<Void> { get }
    var transition: Observable<SettingTransitionConfig> { get }
}

// MARK: - SettingViewModel

protocol SettingViewModel {

    var inputs: SettingViewModelInput { get }
    var outputs: SettingViewModelOutput { get }
    var form: Form { get }

    init()
}

final class SettingViewModelImpl: SettingViewModel {

    /* SettingViewModel */
    let form: Form

    var inputs: SettingViewModelInput { return self }
    var outputs: SettingViewModelOutput { return self }

    /* SettingViewModelInput */
    let buyProductTrigger: PublishRelay<PaymentManager.Product> = .init()
    let restoreTrigger: PublishRelay<Void> = .init()

    private let disposeBag = DisposeBag()
    private let _startInAppPurchase = PublishRelay<Void>()
    private let _transition = PublishRelay<SettingTransitionConfig>()

    init() {
        form = Form()

        if !UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) {
            NotificationCenter.default.rx.notification(.purchasedHideAdMobNotification, object: nil)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (_) in
                    self?.changeStateAdMob()
                })
                .disposed(by: disposeBag)
        }

        subscribeInputsObserver()
        configureCells()
    }
}

// MARK: - Private method

extension SettingViewModelImpl {

    private func subscribeInputsObserver() {
        buyProductTrigger
            .subscribe(onNext: { (product) in
                _ = PaymentManager.shared.buyProduct(product)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] (state) in
                        switch state {
                        case .purchased:
                            Feeder.Notification(.success).notificationOccurred()
                            SVProgressHUD.showSuccess(withStatus: "購入が完了しました！")
                            SVProgressHUD.dismiss(withDelay: 0.5)
                            product.finishPurchased()
                            self?.changeStateAdMob()
                        case .purchasing:
                            SVProgressHUD.show(withStatus: "購入処理中...")
                        }
                    }, onError: { (_) in
                        Feeder.Notification(.error).notificationOccurred()
                        SVProgressHUD.showError(withStatus: "購入が失敗しました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                    })
            })
            .disposed(by: disposeBag)

        restoreTrigger
            .subscribe(onNext: {
                _ = PaymentManager.shared.restore()
                    .subscribe(onNext: { [weak self] (products) in
                        products.forEach { $0.finishPurchased() }
                        Feeder.Notification(.success).notificationOccurred()
                        SVProgressHUD.showSuccess(withStatus: "復元が完了しました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        if products.first(where: { $0 == .hideAdmob }) == nil { return }
                        self?.changeStateAdMob()
                    }, onError: { (_) in
                        Feeder.Notification(.error).notificationOccurred()
                        SVProgressHUD.showError(withStatus: "復元に失敗しました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                    })
            })
            .disposed(by: disposeBag)
    }

    private func configureCells() {
        form
            +++ Section("SNS設定")
                <<< configureTwitterSetting()
                <<< configureMastodonSetting()
            +++ Section("アプリについて")
                <<< configureDeveloper()
                <<< configureSourceCode()
                <<< configureFeatureReportBugs()
                <<< configureHideAdmobPurchase()
                <<< configureReview()
    }

    private func configureTwitterSetting() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "Twitter設定"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                self._transition.accept(.twitter)
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureMastodonSetting() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "Mastodon設定"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                self._transition.accept(.mastodon)
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureDeveloper() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "開発者(Twitter)"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                self._transition.accept(.safari(URL(string: "https://twitter.com/nnsnodnb")!))
                Analytics.Setting.onTapDeveloper()
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureSourceCode() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "ソースコード(GitHub)"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                self._transition.accept(.safari(URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!))
                Analytics.Setting.github()
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureFeatureReportBugs() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "機能要望・バグ報告"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                self._transition.accept(.safari(URL(string: "https://forms.gle/gE5ms3bEM5A85kdVA")!))
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureHideAdmobPurchase() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "アプリ内広告削除(有料)"
            $0.tag = "remove_admob"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isPurchasedRemoveAdMob))
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                if !DTTJailbreakDetection.isJailbroken() {
                    self._startInAppPurchase.accept(())
                    return
                }
                let actions: [AlertConfigurations.Action] = [
                    AlertConfigurations.Action(title: "閉じる", style: .cancel, isPreferredAction: false, handler: nil)
                ]
                let config = AlertConfigurations(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません",
                                                preferredStyle: .alert, actions: actions)
                self._transition.accept(.alert(config))
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureReview() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "レビューする"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                let actions: [AlertConfigurations.Action] = [
                    .init(title: "キャンセル", style: .cancel),
                    .init(title: "開く", style: .default, isPreferredAction: true) { (_) in
                        let reviewURL = URL(string: "\(websiteURL)&action=write-review")!
                        UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                    }
                ]
                let config = AlertConfigurations(title: "AppStoreが開きます", message: nil, preferredStyle: .alert, actions: actions)
                self._transition.accept(.alert(config))
            })
            .disposed(by: disposeBag)
        return row
    }

    private func changeStateAdMob() {
        if !UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) { return }
        guard let purchaseButtonRow: NowPlayingButtonRow = form.rowBy(tag: "remove_admob") else { return }
        purchaseButtonRow.hidden = Condition(booleanLiteral: true)
        purchaseButtonRow.evaluateHidden()
    }
}

// MARK: - SettingViewModelInput

extension SettingViewModelImpl: SettingViewModelInput {}

// MARK: - SettingViewModelOutput

extension SettingViewModelImpl: SettingViewModelOutput {

    var startInAppPurchase: Observable<Void> {
        return _startInAppPurchase.observeOn(MainScheduler.instance).asObservable()
    }

    var transition: Observable<SettingTransitionConfig> {
        return _transition.observeOn(MainScheduler.instance).asObservable()
    }
}
