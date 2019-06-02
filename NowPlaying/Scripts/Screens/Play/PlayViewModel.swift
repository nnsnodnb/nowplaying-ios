//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import MediaPlayer
import RxCocoa
import RxSwift
import UIKit

struct PlayViewModelInput {

    let previousButton: Observable<Void>
    let playButton: Observable<Void>
    let nextButton: Observable<Void>
}

// MARK: - PlayViewModelOutput

protocol PlayViewModelOutput {

    var playButtonImage: Driver<UIImage?> { get }
}

// MARK: - PlayViewModelType

protocol PlayViewModelType {

    var outputs: PlayViewModelOutput { get }
    init(inputs: PlayViewModelInput)
}

final class PlayViewModel: PlayViewModelType {

    var outputs: PlayViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let isPlaying = PublishRelay<Bool>()

    init(inputs: PlayViewModelInput) {
        inputs.previousButton
            .subscribe(onNext: { () in

            })
            .disposed(by: disposeBag)

        inputs.playButton
            .subscribe(onNext: { (_) in

            })
            .disposed(by: disposeBag)

        inputs.nextButton
            .subscribe(onNext: { (_) in

            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {

    var playButtonImage: SharedSequence<DriverSharingStrategy, UIImage?> {
        return isPlaying
            .map { $0 ? R.image.pause() : R.image.play() }
            .asDriver(onErrorJustReturn: nil)
    }
}
