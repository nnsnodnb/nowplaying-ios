//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol PlayViewModelInput {

    var gearButtonTrigger: PublishRelay<Void> { get }
}

protocol PlayViewModelOutput {

}

protocol PlayViewModelType {

    var input: PlayViewModelInput { get }
    var output: PlayViewModelOutput { get }
    init(router: PlayRouter)
}

final class PlayViewModel: PlayViewModelType {

    let gearButtonTrigger: PublishRelay<Void> = .init()

    var input: PlayViewModelInput { return self }
    var output: PlayViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: PlayRouter) {
        gearButtonTrigger
            .subscribe(onNext: {
                router.openSetting()
            })
            .disposed(by: disposeBag)
    }
}

extension PlayViewModel: PlayViewModelInput {}

extension PlayViewModel: PlayViewModelOutput {}
