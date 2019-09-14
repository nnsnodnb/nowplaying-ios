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

// MARK: - SettingViewModelInput

protocol SettingViewModelInput {

    var buyProductTrigger: PublishRelay<PaymentManager.Product> { get }
    var restoreTrigger: PublishRelay<Void> { get }
}

// MARK: - SettingViewModelOutput

protocol SettingViewModelOutput {

    var startInAppPurchase: Observable<Void> { get }
    var pushViewController: Driver<UIViewController> { get }
    var presentViewController: Driver<UIViewController> { get }
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
    private let _pushViewController = PublishRelay<UIViewController>()
    private let _presentViewController = PublishRelay<UIViewController>()

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
        return NowPlayingButtonRow {
            $0.title = "Twitter設定"
        }.onCellSelection { [unowned self] (_, _) in
            let viewController = TwitterSettingViewController()
            self._pushViewController.accept(viewController)
        }
    }

    private func configureMastodonSetting() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "Mastodon設定"
        }.onCellSelection { [unowned self] (_, _) in
            let viewController = MastodonSettingViewController()
            self._pushViewController.accept(viewController)
        }
    }

    private func configureDeveloper() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "開発者(Twitter)"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://twitter.com/nnsnodnb")!)
            self._presentViewController.accept(safariViewController)
            Analytics.Setting.onTapDeveloper()
        }
    }

    private func configureSourceCode() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "ソースコード(GitHub)"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!)
            self._presentViewController.accept(safariViewController)
            Analytics.Setting.github()
        }
    }

    private func configureFeatureReportBugs() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "機能要望・バグ報告"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://forms.gle/gE5ms3bEM5A85kdVA")!)
            safariViewController.dismissButtonStyle = .close
            self._presentViewController.accept(safariViewController)
        }
    }

    private func configureHideAdmobPurchase() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "アプリ内広告削除(有料)"
            $0.tag = "remove_admob"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isPurchasedRemoveAdMob))
        }.onCellSelection { [unowned self] (_, _) in
            if DTTJailbreakDetection.isJailbroken() {
                let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                self._presentViewController.accept(alert)
                return
            }
            self._startInAppPurchase.accept(())
        }
    }

    private func configureReview() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "レビューする"
        }.onCellSelection { [unowned self] (_, _) in
            Analytics.Setting.review()
            let alert = UIAlertController(title: "AppStoreが開きます", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "開く", style: .default) { (_) in
                let reviewURL = URL(string: "\(websiteURL)&action=write-review")!
                DispatchQueue.main.async {
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                }
            })
            alert.preferredAction = alert.actions.last
            self._presentViewController.accept(alert)
        }
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

    var pushViewController: Driver<UIViewController> {
        return _pushViewController.asDriver(onErrorDriveWith: .empty())
    }

    var presentViewController: Driver<UIViewController> {
        return _presentViewController.asDriver(onErrorDriveWith: .empty())
    }
}
