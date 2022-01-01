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
}

final class PlayerRouter: PlayerRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    let setting: PublishRelay<Void> = .init()

    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init() {
        setting.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                let viewController = SettingViewController()
                strongSelf.viewController?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
