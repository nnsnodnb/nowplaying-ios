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
    }
}

// MARK: - SettingViewModelInput

extension SettingViewModel: SettingViewModelInput {}

// MARK: - SettingViewModelOutput

extension SettingViewModel: SettingViewModelOutput {}
