//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Eureka
import Foundation
import RxCocoa
import RxSwift
import SVProgressHUD

final class TwitterSettingViewModel: ProviderSettingViewModelType {

    let title: Observable<String>
    let form: Form

    var input: ProviderSettingViewModelInput { return self }
    var output: ProviderSettingViewModelOutput { return self }

    private let router: ProviderSettingRoutable
    private let disposeBag = DisposeBag()

    private lazy var postFormatHelpViewFooter: (Section) -> Void = {
        return {
            $0.footer = HeaderFooterView<PostFormatHelpView>(.callback {
                return R.nib.postFormatHelpView(owner: nil)!
            })
        }
    }()
    private lazy var purchaseAction: Action<PaymentProduct, BuyTransactionState> = .init {
        return $0.buyProduct()
    }
    private lazy var restoreAction: Action<Void, [PaymentProduct]> = .init {
        return PaymentProduct.restore()
    }

    init(router: ProviderSettingRoutable) {
        self.router = router
        title = .just("Twitter設定")
        form = .init()

        configureForm()
        subscribeActions()
        subscribeUserDefaults()
    }

    func configureForm() {
        func configureCell(row: TwitterSettingRow) -> BaseRow { return row.row }

        form
            +++ Section("Twitter")
                <<< configureCell(row: .accounts)
                <<< configureCell(row: .attachedImageSwitch)
                <<< configureCell(row: .attachedImageType)
                <<< configureCell(row: .purchaseAutoTweet { [unowned self] in
                    switch $0 {
                    case .purchase:
                        SVProgressHUD.show()
                        self.purchaseAction.execute(.autoTweet)
                    case .restore:
                        SVProgressHUD.show()
                        self.restoreAction.execute(())
                    case .userCancel:
                        return
                    }
                })
                <<< configureCell(row: .autoTweetSwitch)
            +++ Section("自動フォーマット", postFormatHelpViewFooter)
                <<< configureCell(row: .tweetFormat)
                <<< configureCell(row: .tweetFormatResetButton { [unowned self] in
                    let alert = UIAlertController.resetPostFormat { [weak self] in
                        Service.resetPostFormat(.twitter)
                        let row = self?.form.rowBy(tag: TwitterSettingRow.tweetFormat.tag) as? TextAreaRow
                        row?.value = .defaultPostFormat
                        row?.updateCell()
                    }
                    self.router.present(alert, animated: true, completion: nil)
                })
    }

    // MARK: - Private method

    private func subscribeActions() {
        purchaseAction.elements
            .filter { $0 == .purchased }
            .map { _ in PaymentProduct.autoTweet }
            .subscribe(onNext: {
                $0.finishPurchased()
                SVProgressHUD.showSuccess(withStatus: "自動ツイートを購入しました")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)

        restoreAction.elements
            .subscribe(onNext: {
                defer { SVProgressHUD.dismiss(withDelay: 1) }
                if $0.isEmpty {
                    SVProgressHUD.showInfo(withStatus: "復元するものがありません")
                    return
                }
                $0.forEach { $0.finishPurchased() }
                SVProgressHUD.showSuccess(withStatus: "復元に成功しました")
            })
            .disposed(by: disposeBag)

        Observable.merge(purchaseAction.errors, restoreAction.errors)
            .subscribe(onNext: {
                print($0)
                SVProgressHUD.showError(withStatus: "エラーが発生しました: \($0)")
                SVProgressHUD.dismiss(withDelay: 1)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private method

    private func subscribeUserDefaults() {
        if UserDefaults.standard.bool(forKey: .isAutoTweetPurchase) { return }
        UserDefaults.standard.rx.change(type: Bool.self, key: .isAutoTweetPurchase)
            .compactMap { $0 }
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .map { _ in }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let purchaseCell = self?.form.rowBy(tag: TwitterSettingRow.purchaseAutoTweet { _ in }.tag),
                    let switchCell = self?.form.rowBy(tag: TwitterSettingRow.autoTweetSwitch.tag) else { return }
                purchaseCell.hidden = .init(booleanLiteral: true)
                switchCell.hidden = .init(booleanLiteral: false)
                purchaseCell.evaluateHidden()
                switchCell.evaluateHidden()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ProviderSettingViewModelInput

extension TwitterSettingViewModel: ProviderSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModel: ProviderSettingViewModelOutput {}
