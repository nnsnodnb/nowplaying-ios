//
//  PlayerRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import RxCocoa
import RxSwift
import UIKit

protocol PlayerRoutable: Routable {
    var setting: PublishRelay<Void> { get }
    var mastodon: PublishRelay<MediaItem> { get }
    var twitter: PublishRelay<MediaItem> { get }
}

final class PlayerRouter: PlayerRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    let setting: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<MediaItem> = .init()
    let twitter: PublishRelay<MediaItem> = .init()

    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init() {
        // 設定
        setting.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                let viewController = SettingViewController()
                strongSelf.viewController?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        // Mastodon
        mastodon.asSignal()
            .emit(onNext: { _ in
                // TODO: トゥート画面に遷移
            })
            .disposed(by: disposeBag)
        // Twitter
        twitter.asSignal()
            .emit(onNext: { _ in
                // TODO: ツイート画面に遷移
            })
            .disposed(by: disposeBag)
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
