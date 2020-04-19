//
//  SettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/27.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import RxCocoa
import RxSwift
import UIKit

protocol SettingViewModelInput {

    var closeTrigger: PublishRelay<Void> { get }
}

protocol SettingViewModelOutput {

    var form: Form { get }
}

protocol SettingViewModelType {

    var input: SettingViewModelInput { get }
    var output: SettingViewModelOutput { get }
    init(router: SettingRouter)
}

final class SettingViewModel: SettingViewModelType {

    let form: Form
    let closeTrigger: PublishRelay<Void> = .init()

    var input: SettingViewModelInput { return self }
    var output: SettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: SettingRouter) {
        form = Form()

        closeTrigger
            .subscribe(onNext: {
                router.close()
            })
            .disposed(by: disposeBag)

        configureForm()
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
                <<< configureCell(row: .purchaseHideAdMob { (action) in
                    // TODO: Implementation
                    print(action)
                })
                <<< configureCell(row: .review)
    }
}

// MARK: - SettingViewModelInput

extension SettingViewModel: SettingViewModelInput {}

// MARK: - SettingViewModelOutput

extension SettingViewModel: SettingViewModelOutput {}
