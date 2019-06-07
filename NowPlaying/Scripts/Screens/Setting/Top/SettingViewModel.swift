//
//  SettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import FirebaseAnalytics
import RxCocoa
import RxSwift
import SafariServices
import StoreKit
import SVProgressHUD
import UIKit

// MARK: - SettingViewModelOutput

protocol SettingViewModelOutput {

    var pushViewController: Driver<UIViewController> { get }
    var presentViewController: Driver<UIViewController> { get }
    var startInAppPurchase: Observable<Void> { get }
}

// MARK: - SettingViewModelType

protocol SettingViewModelType {

    var outputs: SettingViewModelOutput { get }
    var form: Form { get }

    func buyProduct(_ product: PaymentManager.Product)
    func restore()
}

final class SettingViewModel: SettingViewModelType {

    let form: Form

    var outputs: SettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _pushViewController = PublishRelay<UIViewController>()
    private let _presentViewController = PublishRelay<UIViewController>()
    private let _startInAppPurchase = PublishRelay<Void>()

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

        configureSNSSection()
        configureAbout()
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
                    self?.changeStateAdMob()
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
                products.forEach { $0.finishPurchased() }
                SVProgressHUD.showSuccess(withStatus: "復元が完了しました")
                SVProgressHUD.dismiss(withDelay: 0.5)
                if products.first(where: { $0 == .hideAdmob }) == nil { return }
                self?.changeStateAdMob()
            }, onError: { (_) in
                SVProgressHUD.showError(withStatus: "復元に失敗しました")
                SVProgressHUD.dismiss(withDelay: 0.5)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method

extension SettingViewModel {

    private func configureSNSSection() {
        form
            +++ Section("SNS設定") {
                $0.tag = "sns_setting_section"
            }

            // Twitter
            <<< ButtonRow { (row) in
                row.title = "Twitter設定"
                row.tag = "twitter_setting"
                }.cellUpdate { (cell, _) in
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.textColor = UIColor.black
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection { [weak self] (_, _) in
                    let viewController = TwitterSettingViewController()
                    self?._pushViewController.accept(viewController)
            }

            // Mastodon
            <<< ButtonRow { (row) in
                row.title = "Mastodon設定"
                row.tag = "mastodon_setting"
                }.cellUpdate { (cell, _) in
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.textColor = UIColor.black
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection { [weak self] (_, _) in
                    let viewController = MastodonSettingViewController()
                    self?._pushViewController.accept(viewController)
        }
    }

    private func configureAbout() {
        form
            +++ Section("アプリについて")

            <<< NowPlayingButtonRow {
                $0.title = "開発者(Twitter)"
            }.onCellSelection { [weak self] (_, _) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://twitter.com/nnsnodnb")!)
                Analytics.Setting.onTapDeveloper()
                self?._presentViewController.accept(safariViewController)
            }

            <<< NowPlayingButtonRow {
                $0.title = "ソースコード(GitHub)"
            }.onCellSelection { [weak self] (_, _) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!)
                Analytics.Setting.github()
                self?._presentViewController.accept(safariViewController)
            }

            <<< NowPlayingButtonRow {
                $0.title = "バグ報告"
            }.onCellSelection { [weak self] (_, _) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://goo.gl/forms/Ve9hPalUJD3DQW5y2")!)
                self?._presentViewController.accept(safariViewController)
            }

            <<< NowPlayingButtonRow {
                $0.title = "アプリ内広告削除(有料)"
                $0.tag = "remove_admob"
                $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isPurchasedRemoveAdMob))
            }.onCellSelection { [weak self] (_, _) in
                if DTTJailbreakDetection.isJailbroken() {
                    let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self?._presentViewController.accept(alert)
                    return
                }
                self?._startInAppPurchase.accept(())
            }

            <<< NowPlayingButtonRow {
                $0.title = "レビューする"
            }.onCellSelection { (_, _) in
                Analytics.Setting.review()
                SKStoreReviewController.requestReview()
            }
    }

    private func changeStateAdMob() {
        if !UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) { return }
        guard let purchaseButtonRow: NowPlayingButtonRow = form.rowBy(tag: "remove_admob") else { return }
        purchaseButtonRow.hidden = Condition(booleanLiteral: true)
        purchaseButtonRow.evaluateHidden()
    }
}

// MARK: - SettingViewModelOutput

extension SettingViewModel: SettingViewModelOutput {

    var pushViewController: SharedSequence<DriverSharingStrategy, UIViewController> {
        return _pushViewController.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var presentViewController: SharedSequence<DriverSharingStrategy, UIViewController> {
        return _presentViewController.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var startInAppPurchase: Observable<Void> {
        return _startInAppPurchase.observeOn(MainScheduler.instance).asObservable()
    }
}
