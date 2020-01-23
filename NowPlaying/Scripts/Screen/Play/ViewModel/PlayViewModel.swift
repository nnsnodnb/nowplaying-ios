//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift

protocol PlayViewModelInput {

    var gearButtonTrigger: PublishRelay<Void> { get }
    var countUpTrigger: PublishRelay<Void> { get }
}

protocol PlayViewModelOutput {

    var artworkImage: Driver<UIImage> { get }
    var songName: Driver<String?> { get }
    var artistName: Driver<String?> { get }
}

protocol PlayViewModelType {

    var input: PlayViewModelInput { get }
    var output: PlayViewModelOutput { get }
    init(router: PlayRouter)
}

final class PlayViewModel: PlayViewModelType {

    let gearButtonTrigger: PublishRelay<Void> = .init()
    let countUpTrigger: PublishRelay<Void> = .init()

    var input: PlayViewModelInput { return self }
    var output: PlayViewModelOutput { return self }
    var artworkImage: Driver<UIImage> {
        return _artworkImage.asDriver(onErrorJustReturn: R.image.music()!)
    }
    var songName: Driver<String?> {
        return _songName.asDriver(onErrorJustReturn: nil)
    }
    var artistName: Driver<String?> {
        return _artistName.asDriver(onErrorJustReturn: nil)
    }

    private let disposeBag = DisposeBag()
    private let nowPlayingItem: BehaviorRelay<MPMediaItem?> = .init(value: nil)
    private let _artworkImage: PublishRelay<UIImage> = .init()
    private let _songName: PublishRelay<String?> = .init()
    private let _artistName: PublishRelay<String?> = .init()

    init(router: PlayRouter) {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()

        gearButtonTrigger
            .subscribe(onNext: {
                router.openSetting()
            })
            .disposed(by: disposeBag)

        countUpTrigger
            .subscribe(onNext: {
                // TODO: カウントアップ
            })
            .disposed(by: disposeBag)

        nowPlayingItem.map { $0?.artwork?.image ?? R.image.music()! }.bind(to: _artworkImage).disposed(by: disposeBag)
        nowPlayingItem.map { $0?.title }.bind(to: _songName).disposed(by: disposeBag)
        nowPlayingItem.map { $0?.artist }.bind(to: _artistName).disposed(by: disposeBag)

        // 曲が変更されたら通知される
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { $0.nowPlayingItem }
            .bind(to: nowPlayingItem)
            .disposed(by: disposeBag)
    }

    deinit {
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }
}

extension PlayViewModel: PlayViewModelInput {}

extension PlayViewModel: PlayViewModelOutput {}
