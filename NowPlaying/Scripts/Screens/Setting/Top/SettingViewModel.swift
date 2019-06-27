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
import SVProgressHUD
import UIKit

struct SettingViewModelInput {

    let viewController: UIViewController
}

// MARK: - SettingViewModelOutput

protocol SettingViewModelOutput {

    var startInAppPurchase: Observable<Void> { get }
}

// MARK: - SettingViewModelType

protocol SettingViewModelType {

    var outputs: SettingViewModelOutput { get }
    var form: Form { get }

    init(inputs: SettingViewModelInput)
    func buyProduct(_ product: PaymentManager.Product)
    func restore()
}

final class SettingViewModel: SettingViewModelType {

    let form: Form

    var outputs: SettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _startInAppPurchase = PublishRelay<Void>()
    private let inputs: SettingViewModelInput

    init(inputs: SettingViewModelInput) {
        self.inputs = inputs
        form = Form()

        if !UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) {
            NotificationCenter.default.rx.notification(.purchasedHideAdMobNotification, object: nil)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (_) in
                    self?.changeStateAdMob()
                })
                .disposed(by: disposeBag)
        }

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

    private func configureCells() {
        form
            +++ Section("SNS設定")
                <<< configureTwitterSetting()
                <<< configureMastodonSetting()
            +++ Section("アプリについて")
                <<< configureDeveloper()
                <<< configureSourceCode()
                <<< configureReportBugs()
                <<< configureHideAdmobPurchase()
                <<< configureReview()
    }

    private func configureTwitterSetting() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "Twitter設定"
        }.onCellSelection { [unowned self] (_, _) in
            let viewController = TwitterSettingViewController()
            self.inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func configureMastodonSetting() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "Mastodon設定"
        }.onCellSelection { [unowned self] (_, _) in
            let viewController = MastodonSettingViewController()
            self.inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func configureDeveloper() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "開発者(Twitter)"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://twitter.com/nnsnodnb")!)
            self.inputs.viewController.present(safariViewController, animated: true, completion: nil)
            Analytics.Setting.onTapDeveloper()
        }
    }

    private func configureSourceCode() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "ソースコード(GitHub)"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!)
            self.inputs.viewController.present(safariViewController, animated: true, completion: nil)
            Analytics.Setting.github()
        }
    }

    private func configureReportBugs() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "バグ報告"
        }.onCellSelection { [unowned self] (_, _) in
            let safariViewController = SFSafariViewController(url: URL(string: "https://goo.gl/forms/Ve9hPalUJD3DQW5y2")!)
            self.inputs.viewController.present(safariViewController, animated: true, completion: nil)
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
                self.inputs.viewController.present(alert, animated: true, completion: nil)
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
            self.inputs.viewController.present(alert, animated: true, completion: nil)
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

    var startInAppPurchase: Observable<Void> {
        return _startInAppPurchase.observeOn(MainScheduler.instance).asObservable()
    }
}
