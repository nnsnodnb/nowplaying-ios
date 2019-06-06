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
}

// MARK: - TwitterSettingViewModelType

protocol TwitterSettingViewModelType {

    var outputs: TwitterSettingViewModelOutput { get }
    var form: Form { get }
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {

    let form: Form

    var outputs: TwitterSettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _presentViewController = PublishRelay<UIViewController>()

    init() {
        form = Form()

        configureCells()
    }

    // MARK: - Private method

    private func configureCells() {
        form
            +++ Section("Twitter") {
                $0.tag = "twitter_section"
            }

            <<< ButtonRow() { (row) in
                row.title = !TwitterClient.shared.isLogin ? "ログイン" : "ログアウト"
                row.tag = "twitter_login"
            }.cellUpdate { (cell, _) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { (cell, _) in
                SVProgressHUD.show()
                if TwitterClient.shared.isLogin {
                    AuthManager.shared.logout {
                        SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログイン"
                        }
                        Analytics.TwitterSetting.logout()
                    }
                } else {
                    AuthManager.shared.login {
                        SVProgressHUD.showSuccess(withStatus: "ログインしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログアウト"
                        }
                        Analytics.TwitterSetting.login()
                    }
                }
            }

            <<< SwitchRow() { (row) in
                row.title = "アートワークを添付"
                row.value = UserDefaults.bool(forKey: .isWithImage)
            }.onChange { (row) in
                UserDefaults.set(row.value!, forKey: .isWithImage)
                Analytics.TwitterSetting.changeWithArtwork(row.value!)
            }

            <<< ButtonRow() { (row) in
                row.title = "自動ツイートを購入"
                row.tag = "auto_tweet_purchase"
                row.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isAutoTweetPurchase))
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { [weak self] (cell, row) in
                guard !DTTJailbreakDetection.isJailbroken() else {
                    let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self?._presentViewController.accept(alert)
                    return
                }
//                if self.isProces {
//                    SVProgressHUD.showInfo(withStatus: "処理中です")
//                    return
//                }
//                guard let product = self.autoTweetProduct else {
//                    SVProgressHUD.showInfo(withStatus: "少し時間をおいて試してみてください")
//                    return
//                }
//                self.isProces = true
//                self.showSelectPurchaseType(product: product)
            }
            <<< SwitchRow() {
                $0.title = "自動ツイート"
                $0.value = UserDefaults.bool(forKey: .isAutoTweet)
                $0.tag = "auto_tweet_switch"
                $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                    return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
                }
            }.onChange { [weak self] (row) in
                UserDefaults.set(row.value!, forKey: .isAutoTweet)
                Analytics.TwitterSetting.changeAutoTweet(row.value!)
                if !row.value! || UserDefaults.bool(forKey: .isShowAutoTweetAlert) { return }
                let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもツイートされますが、iOS上での制約のため長時間には対応できません。",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?._presentViewController.accept(alert)
                UserDefaults.set(true, forKey: .isShowAutoTweetAlert)
        }
    }
}

extension TwitterSettingViewModel: TwitterSettingViewModelOutput {

    var presentViewController: SharedSequence<DriverSharingStrategy, UIViewController> {
        return _presentViewController.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }
}
