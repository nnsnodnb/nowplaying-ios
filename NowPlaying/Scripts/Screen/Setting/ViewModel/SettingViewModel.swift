//
//  SettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/27.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Eureka
import RxCocoa
import RxSwift
import StoreKit
import SVProgressHUD
import UIKit
import Umbrella

protocol SettingViewModelInput {

    var closeTrigger: PublishRelay<Void> { get }
}

protocol SettingViewModelOutput {

    var form: Form { get }
}

protocol SettingViewModelType {

    var input: SettingViewModelInput { get }
    var output: SettingViewModelOutput { get }
    init(router: SettingRoutable)
}

final class SettingViewModel: SettingViewModelType {

    let form: Form
    let closeTrigger: PublishRelay<Void> = .init()

    var input: SettingViewModelInput { return self }
    var output: SettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    private lazy var restoreAction: Action<Void, SKPaymentQueue> = .init {
        return SKPaymentQueue.default().rx.restoreCompletedTransactions()
    }

    init(router: SettingRoutable) {
        form = Form()

        closeTrigger
            .subscribe(onNext: {
                router.close()
            })
            .disposed(by: disposeBag)

        configureForm()
        subscribeActions()
    }
}

// MARK: - Private method

extension SettingViewModel {

    private func configureForm() {

        func configureCell(row: SettingRow) -> ButtonRow {
            return .init(row.tag) {
                $0.title = row.title
                $0.presentationMode = row.presentationMode
                $0.hidden = row.hidden
            }
        }

        form
            +++ Section("SNS設定")
                <<< configureCell(row: .twitter)
                <<< configureCell(row: .mastodon)
            +++ Section("アプリについて")
                <<< configureCell(row: .developer)
                <<< configureCell(row: .sourceCode)
                <<< configureCell(row: .featureReportsAndBugs)
                <<< configureCell(row: .purchaseHideAdMob { [unowned self] (action) in
                    switch action {
                    case .purchase:
                        SVProgressHUD.show()
                    case .restore:
                        SVProgressHUD.show()
                        self.restoreAction.execute()
                    case .userCancel:
                        return
                    }
                })
                <<< configureCell(row: .review)
    }

    private func subscribeActions() {
        restoreAction.elements
            .map { $0.transactions.map { PaymentProduct(rawValue: $0.payment.productIdentifier) } }
            .subscribe(onNext: { [weak self] in
                if $0.isEmpty {
                    SVProgressHUD.showInfo(withStatus: "復元するものがありません")
                    SVProgressHUD.dismiss(withDelay: 1)
                    return
                }
                $0.forEach { $0?.finishPurchased() }
                defer {
                    SVProgressHUD.showSuccess(withStatus: "復元に成功しました")
                    SVProgressHUD.dismiss(withDelay: 1)
                }
                guard $0.first(where: { $0 == .hideAdMob }) != nil else { return }
                guard let wself = self, let row = wself.form.rowBy(tag: "purchase_hide_admob") else { return }
                row.hidden = .init(booleanLiteral: true)
                row.evaluateHidden()
            })
            .disposed(by: disposeBag)

        restoreAction.errors
            .subscribe(onNext: { (actionError) in
                print(actionError)
                SVProgressHUD.showError(withStatus: "エラーが発生しました: \(actionError)")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - SettingViewModelInput

extension SettingViewModel: SettingViewModelInput {}

// MARK: - SettingViewModelOutput

extension SettingViewModel: SettingViewModelOutput {}
