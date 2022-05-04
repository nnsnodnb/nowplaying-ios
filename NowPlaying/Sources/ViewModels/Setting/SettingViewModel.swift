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
    var item: PublishRelay<SettingViewController.Item> { get }
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
    let item: PublishRelay<SettingViewController.Item> = .init()
    // MARK: - Outputs Sources
    let dataSource: Driver<[SettingViewController.SectionModel]>
    // MARK: - Properties
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }

    private let disposeBag = DisposeBag()
    private let router: SettingRoutable

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
        self.router = router

        // 閉じる
        dismiss
            .bind(to: router.dismiss)
            .disposed(by: disposeBag)
        let socialType = item.asObservable()
            .compactMap { item -> SocialType? in
                guard case let .socialType(socialType) = item else { return nil }
                return socialType
            }
            .share(replay: 1)
        // Twitter設定
        socialType
            .filter { $0 == .twitter }
            .map { _ in }
            .bind(to: router.twitter)
            .disposed(by: disposeBag)
        // Mastodon設定
        socialType
            .filter { $0 == .mastodon }
            .map { _ in }
            .bind(to: router.mastodon)
            .disposed(by: disposeBag)
        // リンク
        item.asObservable()
            .compactMap { item -> SettingViewController.Link? in
                guard case let .link(link) = item else { return nil }
                return link
            }
            .map { $0.url }
            .bind(to: router.safari)
            .disposed(by: disposeBag)
        // 広告削除
        item.asObservable()
            .filter { $0 == .removeAdMob }
            .subscribe(onNext: { _ in
                // TODO: StoreKit
            })
            .disposed(by: disposeBag)
        // レビュー
        item.asObservable()
            .filter { $0 == .review }
            .map { _ in }
            .bind(to: router.appStore)
            .disposed(by: disposeBag)
    }
}

// MARK: - SettingViewModelInputs
extension SettingViewModel: SettingViewModelInputs {}

// MARK: - SettingViewModelOutputs
extension SettingViewModel: SettingViewModelOutputs {}
