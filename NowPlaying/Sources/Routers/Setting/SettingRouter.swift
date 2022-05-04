//
//  SettingRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import RxCocoa
import RxSwift
import UIKit

protocol SettingRoutable: Routable {
    var dismiss: PublishRelay<Void> { get }
    var twitter: PublishRelay<Void> { get }
    var mastodon: PublishRelay<Void> { get }
}

final class SettingRouter: SettingRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    let dismiss: PublishRelay<Void> = .init()
    let twitter: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<Void> = .init()

    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init() {
        // 閉じる
        dismiss.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                strongSelf.viewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        // Twitter設定
        twitter.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                // TODO: 画面遷移
            })
            .disposed(by: disposeBag)
        // Mastodon設定
        mastodon.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                // TODO: 画面遷移
            })
            .disposed(by: disposeBag)
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
