//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import Feeder
import FirebaseAnalytics
import Foundation
import RxCocoa
import RxSwift
import SVProgressHUD

enum TwitterSettingTransition {
    case manage, alert(AlertConfigurations)
}

// MARK: - TwitterSettingViewModelInput

protocol TwitterSettingViewModelInput {

    var buyProductTrigger: PublishRelay<PaymentManager.Product> { get }
    var restoreTrigger: PublishRelay<Void> { get }
}

// MARK: - TwitterSettingViewModelOutput

protocol TwitterSettingViewModelOutput {

    var startInAppPurchase: Observable<Void> { get }
    var transition: Observable<TwitterSettingTransition> { get }
}

// MARK: - TwitterSettingViewModelType

protocol TwitterSettingViewModel {

    var inputs: TwitterSettingViewModelInput { get }
    var outputs: TwitterSettingViewModelOutput { get }
    var form: Form { get }

    init()
}

final class TwitterSettingViewModelImpl: TwitterSettingViewModel {

    /* TwitterSettingViewModel */
    let form: Form

    var inputs: TwitterSettingViewModelInput { return self }
    var outputs: TwitterSettingViewModelOutput { return self }

    /* TwitterSettingViewModelInput */
    let buyProductTrigger: PublishRelay<PaymentManager.Product> = .init()
    let restoreTrigger: PublishRelay<Void> = .init()

    private let disposeBag = DisposeBag()
    private let _startInAppPurchase = PublishRelay<Void>()
    private let _transition = PublishRelay<TwitterSettingTransition>()

    init() {
        form = Form()

        configureCells()
    }
}

// MARK: - Private method (Subscribe)

extension TwitterSettingViewModelImpl {

    private func subscribeInputs() {
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
                            self?.changeStateAutoTweet()
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
                    Feeder.Notification(.success).notificationOccurred()
                    SVProgressHUD.showSuccess(withStatus: "復元が完了しました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                }, onError: { (_) in
                    Feeder.Notification(.error).notificationOccurred()
                    SVProgressHUD.showError(withStatus: "復元に失敗しました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method (Form)

extension TwitterSettingViewModelImpl {

    private func configureCells() {
        form
            +++ Section("Twitter")
                <<< configureAccounts()
                <<< configureWithImage()
                <<< configureWithImageType()
                <<< configurePurchase()
                <<< configureAutoTweet()

            +++ Section("投稿フォーマット", configureHeaderForTweetFormat())
                <<< configureTweetFormat()
                <<< configureFormatReset()
    }

    private func configureAccounts() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "アカウント管理"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                // TODO: AccountManageViewController
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureWithImage() -> SwitchRow {
        return SwitchRow {
            $0.title = "画像を添付"
            $0.value = UserDefaults.bool(forKey: .isWithImage)
        }.onChange {
            UserDefaults.set($0.value!, forKey: .isWithImage)
            Analytics.TwitterSetting.changeWithArtwork($0.value!)
        }
    }

    private func configureWithImageType() -> ActionSheetRow<String> {
        return ActionSheetRow<String> {
            $0.title = "投稿時の画像"
            $0.options = ["アートワークのみ", "再生画面のスクリーンショット"]
            $0.value = UserDefaults.string(forKey: .tweetWithImageType)!
        }.onCellSelection { (_, _) in
            Feeder.Impact(.light).impactOccurred()
        }.onChange { (row) in
            guard let value = row.value, let type = WithImageType(rawValue: value) else { return }
            UserDefaults.set(type.rawValue, forKey: .tweetWithImageType)
        }
    }

    private func configurePurchase() -> NowPlayingButtonRow {
        let row = NowPlayingButtonRow {
            $0.title = "自動ツイートを購入"
            $0.tag = "auto_tweet_purchase"
            $0.hidden = Condition(booleanLiteral: UserDefaults.bool(forKey: .isAutoTweetPurchase))
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { (_, _) in
                if !DTTJailbreakDetection.isJailbroken() {
                    self._startInAppPurchase.accept(())
                    return
                }
                // TODO: 脱獄検知アラート
//                let alert = UIAlertController(title: "脱獄が検知されました", message: "脱獄された端末ではこの操作はできません", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
////                self?.inputs.viewController.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        return row
    }

    private func configureAutoTweet() -> SwitchRow {
        return SwitchRow {
            $0.title = "自動ツイート"
            $0.value = UserDefaults.bool(forKey: .isAutoTweet)
            $0.tag = "auto_tweet_switch"
            $0.hidden = Condition.function(["auto_tweet_purchase"]) { (form) -> Bool in
                return !form.rowBy(tag: "auto_tweet_purchase")!.isHidden
            }
        }.onChange { [unowned self] in
            UserDefaults.set($0.value!, forKey: .isAutoTweet)
            Analytics.TwitterSetting.changeAutoTweet($0.value!)
            if !$0.value! || UserDefaults.bool(forKey: .isShowAutoTweetAlert) { return }
            // TODO: アラート
            let alert = UIAlertController(title: "お知らせ", message: "バッググラウンドでもツイートされますが、iOS上での制約のため長時間には対応できません。",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.inputs.viewController.present(alert, animated: true) {
//                UserDefaults.set(true, forKey: .isShowAutoTweetAlert)
//            }
            Feeder.Impact(.heavy).impactOccurred()
        }
    }

    private func configureHeaderForTweetFormat() -> (Section) -> Void {
        return {
            let postFormatHelpView = R.nib.postFormatHelpView
            $0.footer = HeaderFooterView<PostFormatHelpView>(.nibFile(name: postFormatHelpView.name,
                                                                      bundle: postFormatHelpView.bundle))
        }
    }

    private func configureTweetFormat() -> TextAreaRow {
        return TextAreaRow {
            $0.placeholder = "ツイートフォーマット"
            $0.tag = "tweet_format"
            $0.value = UserDefaults.string(forKey: .tweetFormat)
        }.onChange { (row) in
            guard let value = row.value, !value.isEmpty else { return }
            UserDefaults.set(value, forKey: .tweetFormat)
        }
    }

    private func configureFormatReset() -> ButtonRow {
        let row = ButtonRow {
            $0.title = "リセットする"
        }
        row.rx.onCellSelection()
            .subscribe(onNext: { [unowned self] (_, _) in
                // TODO: アラート表示
                Feeder.Notification(.warning).notificationOccurred()
            })
            .disposed(by: disposeBag)
        return row
//        .onCellSelection { [unowned self] (_, _) in
//            let alert = UIAlertController(title: "投稿フォーマットをリセットします", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
//            alert.addAction(UIAlertAction(title: "リセット", style: .destructive) { [unowned self] (_) in
//                guard let tweetFormatRow: TextAreaRow = self.form.rowBy(tag: "tweet_format") else { return }
//                DispatchQueue.main.async {
//                    tweetFormatRow.baseValue = String.defaultPostFormat
//                    tweetFormatRow.updateCell()
//                }
//            })
////            self.inputs.viewController.present(alert, animated: true, completion: nil)
//            Feeder.Notification(.warning).notificationOccurred()
//        }
    }
}

// MARK: - Private method (Utilities)

extension TwitterSettingViewModelImpl {

    private func changeStateAutoTweet() {
        if !UserDefaults.bool(forKey: .isAutoTweetPurchase) { return }
        guard let purchaseButtonRow: NowPlayingButtonRow = form.rowBy(tag: "auto_tweet_purchase"),
            let autoTweetSwitchRow: SwitchRow = form.rowBy(tag: "auto_tweet_switch") else { return }
        purchaseButtonRow.hidden = Condition(booleanLiteral: true)
        autoTweetSwitchRow.hidden = Condition(booleanLiteral: false)
        purchaseButtonRow.evaluateHidden()
        autoTweetSwitchRow.evaluateHidden()
    }
}

// MARK: - TwitterSettingViewModelInput

extension TwitterSettingViewModelImpl: TwitterSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModelImpl: TwitterSettingViewModelOutput {

    var startInAppPurchase: Observable<Void> {
        return _startInAppPurchase.observeOn(MainScheduler.instance).asObservable()
    }

    var transition: Observable<TwitterSettingTransition> {
        return _transition.observeOn(MainScheduler.instance).asObservable()
    }
}
