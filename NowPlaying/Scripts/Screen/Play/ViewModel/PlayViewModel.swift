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
import StoreKit

protocol PlayViewModelInput {

    var playPauseButtonTrigger: PublishRelay<Void> { get }
    var previousButtonTrigger: PublishRelay<Void> { get }
    var nextButtonTrigger: PublishRelay<Void> { get }
    var gearButtonTrigger: PublishRelay<Void> { get }
    var mastodonButtonTrigger: PublishRelay<Void> { get }
    var twitterButtonTrigger: PublishRelay<Void> { get }
    var countUpTrigger: PublishRelay<Void> { get }
}

protocol PlayViewModelOutput {

    var artworkImage: Driver<UIImage> { get }
    var artworkScale: Driver<CGFloat> { get }
    var songName: Driver<String> { get }
    var artistName: Driver<String> { get }
    var playButtonImage: Driver<UIImage> { get }
}

protocol PlayViewModelType {

    var input: PlayViewModelInput { get }
    var output: PlayViewModelOutput { get }
    init(router: PlayRoutable)
}

final class PlayViewModel: PlayViewModelType {

    let playPauseButtonTrigger: PublishRelay<Void> = .init()
    let previousButtonTrigger: PublishRelay<Void> = .init()
    let nextButtonTrigger: PublishRelay<Void> = .init()
    let gearButtonTrigger: PublishRelay<Void> = .init()
    let mastodonButtonTrigger: PublishRelay<Void> = .init()
    let twitterButtonTrigger: PublishRelay<Void> = .init()
    let countUpTrigger: PublishRelay<Void> = .init()

    var input: PlayViewModelInput { return self }
    var output: PlayViewModelOutput { return self }
    var artworkImage: Driver<UIImage> {
        return _artworkImage.asDriver(onErrorJustReturn: R.image.music()!)
    }
    var artworkScale: Driver<CGFloat> {
        return _artworkScale.asDriver(onErrorJustReturn: 1)
    }
    var songName: Driver<String> {
        return _songName.asDriver(onErrorJustReturn: "")
    }
    var artistName: Driver<String> {
        return _artistName.asDriver(onErrorJustReturn: "")
    }
    var playButtonImage: Driver<UIImage> {
        return playbackState.map { $0 == .playing ? R.image.pause()! : R.image.play()! }.asDriver(onErrorJustReturn: R.image.pause()!)
    }

    private let router: PlayRoutable
    private let disposeBag = DisposeBag()
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let nowPlayingItem: BehaviorRelay<MPMediaItem?>
    private let playbackState: BehaviorRelay<MPMusicPlaybackState>
    private let _artworkImage: PublishRelay<UIImage> = .init()
    private let _artworkScale: PublishRelay<CGFloat> = .init()
    private let _songName: PublishRelay<String> = .init()
    private let _artistName: PublishRelay<String> = .init()

    private var isExistUser: Binder<(Service, MPMediaItem)> {
        return .init(self) {
            if User.isExists(service: $1.0) {
                $0.router.openPostView(service: $1.0, item: $1.1)
            } else {
                $0.router.notExistServiceUser()
            }
        }
    }

    init(router: PlayRoutable) {
        self.router = router
        nowPlayingItem = .init(value: musicPlayer.nowPlayingItem)
        playbackState = .init(value: musicPlayer.playbackState)

        musicPlayer.beginGeneratingPlaybackNotifications()

        playPauseButtonTrigger
            .withLatestFrom(playbackState) { $1 }
            .map { $0 == .playing }
            .bind(to: musicPlayer.isPlay)
            .disposed(by: disposeBag)

        previousButtonTrigger.bind(to: musicPlayer.skipToPreviousItem).disposed(by: disposeBag)
        nextButtonTrigger.bind(to: musicPlayer.skipToNextItem).disposed(by: disposeBag)

        gearButtonTrigger
            .subscribe(onNext: {
                router.openSetting()
            })
            .disposed(by: disposeBag)

        mastodonButtonTrigger
            .withLatestFrom(nowPlayingItem)
            .compactMap { $0 }
            .map { (.mastodon, $0) }
            .bind(to: isExistUser)
            .disposed(by: disposeBag)

        twitterButtonTrigger
            .withLatestFrom(nowPlayingItem)
            .compactMap { $0 }
            .map { (.twitter, $0) }
            .bind(to: isExistUser)
            .disposed(by: disposeBag)

        countUpTrigger
            .subscribe(onNext: {
                var count = UserDefaults.standard.integer(forKey: .appOpenCount)
                count += 1
                UserDefaults.standard.set(count, forKey: .appOpenCount)
                if count == 15 {
                    SKStoreReviewController.requestReview()
                    UserDefaults.standard.set(0, forKey: .appOpenCount)
                }
            })
            .disposed(by: disposeBag)

        playbackState.map { $0 == .playing ? 1 : 0.9 }.bind(to: _artworkScale).disposed(by: disposeBag)

        nowPlayingItem.map { $0?.artwork?.image ?? R.image.music()! }.bind(to: _artworkImage).disposed(by: disposeBag)
        nowPlayingItem.map { $0?.title ?? "" }.bind(to: _songName).disposed(by: disposeBag)
        nowPlayingItem.map { $0?.artist ?? "" }.bind(to: _artistName).disposed(by: disposeBag)

        checkMediaLibraryAuthorization()
        subscribeNotifications()
    }

    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }

    // MARK: - Private method

    private func checkMediaLibraryAuthorization() {
        MPMediaLibrary.rx.requestAuthorization()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (status) in
                guard let wself = self else { return }
                switch status {
                case .authorized:
                    wself.nowPlayingItem.accept(wself.musicPlayer.nowPlayingItem)
                    wself.playbackState.accept(wself.musicPlayer.playbackState)
                case .denied:
                    // TODO: アラート表示
                    break
                case .notDetermined, .restricted:
                    break
                @unknown default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    private func subscribeNotifications() {
        // 曲が変更されたら通知される
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { $0.nowPlayingItem }
            .bind(to: nowPlayingItem)
            .disposed(by: disposeBag)

        // 曲の再生状態が変更されたら通知される
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { $0.playbackState }
            .bind(to: playbackState)
            .disposed(by: disposeBag)
    }
}

extension PlayViewModel: PlayViewModelInput {}

extension PlayViewModel: PlayViewModelOutput {}
