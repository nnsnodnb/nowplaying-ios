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
import UIKit

// MARK: - SettingViewModelOutput

protocol SettingViewModelOutput {

    var pushViewController: Driver<UIViewController> { get }
    var presentViewController: Driver<UIViewController> { get }
}

// MARK: - SettingViewModelType

protocol SettingViewModelType {

    var outputs: SettingViewModelOutput { get }
    var form: Form { get }
}

final class SettingViewModel: SettingViewModelType {

    let form: Form

    var outputs: SettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _pushViewController = PublishRelay<UIViewController>()
    private let _presentViewController = PublishRelay<UIViewController>()

    init() {
        form = Form()

        configureSNSSection()
        configureAbout()
    }

    // MARK: - Private method

    private func configureSNSSection() {
        form
            +++ Section("SNS設定") {
                $0.tag = "sns_setting_section"
            }

            // Twitter
            <<< ButtonRow() { (row) in
                row.title = "Twitter設定"
                row.tag = "twitter_setting"
            }.cellUpdate { (cell, _) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                let viewController = TwitterSettingViewController()
                self?._pushViewController.accept(viewController)
            }

            // Mastodon
            <<< ButtonRow() { (row) in
                row.title = "Mastodon設定"
                row.tag = "mastodon_setting"
            }.cellUpdate { (cell, _) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                let viewController = MastodonSettingViewController()
                self?._pushViewController.accept(viewController)
            }
    }

    private func configureAbout() {
        form
            +++ Section("アプリについて")

            <<< ButtonRow() {
                $0.title = "開発者(Twitter)"
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://twitter.com/nnsnodnb")!)
                Analytics.Setting.onTapDeveloper()
                self?._presentViewController.accept(safariViewController)
            }

            <<< ButtonRow() {
                $0.title = "ソースコード(GitHub)"
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!)
                Analytics.Setting.github()
                self?._presentViewController.accept(safariViewController)
            }

            <<< ButtonRow() {
                $0.title = "バグ報告"
            }.cellUpdate { (cell, _) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (_, _) in
                let safariViewController = SFSafariViewController(url: URL(string: "https://goo.gl/forms/Ve9hPalUJD3DQW5y2")!)
                self?._presentViewController.accept(safariViewController)
            }

            <<< ButtonRow() {
                $0.title = "アプリ内広告削除(有料)"
                $0.tag = "remove_admob"
                $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isPurchasedRemoveAdMob))
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                if DTTJailbreakDetection.isJailbroken() {
                    let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self?._presentViewController.accept(alert)
                    return
                }
//                if self.isProcess {
//                    SVProgressHUD.showInfo(withStatus: "処理中です")
//                    return
//                }
//                guard let product = self.products.last else {
//                    SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
//                    return
//                }
//                self.isProcess = true
//                self.showSelectPurchaseType(product: product)
            }

            <<< ButtonRow() {
                $0.title = "レビューする"
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { (cell, row) in
                Analytics.Setting.review()
                SKStoreReviewController.requestReview()
        }

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
}
