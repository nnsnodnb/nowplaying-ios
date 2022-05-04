//
//  SettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import Foundation
import RxCocoa
import RxSwift

protocol SettingViewModelInputs: AnyObject {
    var dismiss: PublishRelay<Void> { get }
    var twitter: PublishRelay<Void> { get }
    var mastodon: PublishRelay<Void> { get }
}

protocol SettingViewModelOutputs: AnyObject {
    var dataSource: Driver<[SettingViewController.SectionModel]> { get }
}

protocol SettingViewModelType: AnyObject {
    var inputs: SettingViewModelInputs { get }
    var outputs: SettingViewModelOutputs { get }
}

final class SettingViewModel: SettingViewModelType {
    // MARK: - Inputs Sources
    let dismiss: PublishRelay<Void> = .init()
    let twitter: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<Void> = .init()
    // MARK: - Outputs Sources
    let dataSource: Driver<[SettingViewController.SectionModel]>
    // MARK: - Properties
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }

    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init(router: SettingRoutable) {
        self.dataSource = .just([
            .init(
                model: .sns,
                items: [
                    .socialType(.twitter),
                    .socialType(.mastodon)
                ]
            ),
            .init(
                model: .app,
                items: [
                    .link(.developer),
                    .link(.github),
                    .link(.contact),
                    .removeAdMob,
                    .review
                ]
            )
        ])

        // 閉じる
        dismiss
            .bind(to: router.dismiss)
            .disposed(by: disposeBag)
        // Twitter設定
        twitter
            .bind(to: router.twitter)
            .disposed(by: disposeBag)
        // Mastodon設定
        mastodon
            .bind(to: router.mastodon)
            .disposed(by: disposeBag)
    }
}

// MARK: - SettingViewModelInputs
extension SettingViewModel: SettingViewModelInputs {}

// MARK: - SettingViewModelOutputs
extension SettingViewModel: SettingViewModelOutputs {}
