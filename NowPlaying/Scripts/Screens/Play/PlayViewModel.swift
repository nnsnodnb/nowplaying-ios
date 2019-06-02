//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import MediaPlayer
import RxCocoa
import RxSwift
import StoreKit
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
    func countUpOpenCount()
}

final class PlayViewModel: PlayViewModelType {

    var outputs: PlayViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let isPlaying = PublishRelay<Bool>()

    init(inputs: PlayViewModelInput) {
        inputs.previousButton
            .subscribe(onNext: { () in
                MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
                Analytics.logEvent("tap", parameters: [
                    "type": "action",
                    "button": "previous"]
                )
            })
            .disposed(by: disposeBag)

        inputs.playButton
            .subscribe(onNext: { [weak self] (_) in
                let isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
                if isPlay {
                    MPMusicPlayerController.systemMusicPlayer.pause()
                } else {
                    MPMusicPlayerController.systemMusicPlayer.play()
                }
                Analytics.logEvent("tap", parameters: [
                    "type": "action",
                    "button": isPlay ? "pause" : "play"]
                )
                self?.isPlaying.accept(isPlay)
            })
            .disposed(by: disposeBag)

        inputs.nextButton
            .subscribe(onNext: { (_) in
                MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
                Analytics.logEvent("tap", parameters: [
                    "type": "action",
                    "button": "next"]
                )
            })
            .disposed(by: disposeBag)

        isPlaying.accept(MPMusicPlayerController.systemMusicPlayer.playbackState == .playing)
    }

    func countUpOpenCount() {
        var count = UserDefaults.integer(forKey: .appOpenCount)
        count += 1
        UserDefaults.set(count, forKey: .appOpenCount)
        if count == 15 {
            SKStoreReviewController.requestReview()
            UserDefaults.set(0, forKey: .appOpenCount)
        }
    }
}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {

    var playButtonImage: SharedSequence<DriverSharingStrategy, UIImage?> {
        return isPlaying
            .map { $0 ? R.image.pause() : R.image.play() }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
    }
}
