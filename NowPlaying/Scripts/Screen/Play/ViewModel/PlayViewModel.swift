//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MediaPlayer
import RxCocoa
import RxSwift
import StoreKit
import UIKit

protocol PlayViewModelInput {

    var playPauseButtonTrigger: PublishRelay<Void> { get }
    var previousButtonTrigger: PublishRelay<Void> { get }
    var nextButtonTrigger: PublishRelay<Void> { get }
    var gearButtonTrigger: PublishRelay<Void> { get }
    var mastodonButtonTrigger: PublishRelay<Void> { get }
    var twitterButtonTrigger: PublishRelay<Void> { get }
    var countUpTrigger: PublishRelay<Void> { get }
    var tookScreenshot: PublishRelay<UIImage> { get }
}

protocol PlayViewModelOutput {

    var artworkImage: Observable<UIImage> { get }
    var artworkScale: Observable<CGFloat> { get }
    var songName: Observable<String> { get }
    var artistName: Observable<String> { get }
    var playButtonImage: Observable<UIImage> { get }
    var takeScreenshot: Observable<Void> { get }
    var hideAdMob: Observable<Bool> { get }
}

protocol PlayViewModelType {

    var inputs: PlayViewModelInput { get }
    var outputs: PlayViewModelOutput { get }
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
    let tookScreenshot: PublishRelay<UIImage> = .init()

    var inputs: PlayViewModelInput { return self }
    var outputs: PlayViewModelOutput { return self }
    var artworkImage: Observable<UIImage> {
        return nowPlayingItem.map { $0?.artwork?.image ?? R.image.music()! }.observeOn(MainScheduler.instance)
    }
    var artworkScale: Observable<CGFloat> {
        return playbackState.map { $0 == .playing ? 1 : 0.9 }.observeOn(MainScheduler.instance)
    }
    var songName: Observable<String> {
        return nowPlayingItem.map { $0?.title ?? "" }.observeOn(MainScheduler.instance)
    }
    var artistName: Observable<String> {
        return nowPlayingItem.map { $0?.artist ?? "" }.observeOn(MainScheduler.instance)
    }
    var playButtonImage: Observable<UIImage> {
        return playbackState.map { $0 == .playing ? R.image.pause()! : R.image.play()! }.observeOn(MainScheduler.instance)
    }
    var takeScreenshot: Observable<Void> {
        return nowPlayingItem.compactMap { $0 }.distinctUntilChanged().map { _ in }.asObservable()
    }
    var hideAdMob: Observable<Bool> {
        return UserDefaults.standard.rx.change(type: Bool.self, key: .isPurchasedRemoveAdMob)
            .compactMap { $0 }
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observeOn(MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
    }

    private let router: PlayRoutable
    private let disposeBag = DisposeBag()
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let nowPlayingItem: BehaviorRelay<MPMediaItem?> = .init(value: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
    private let playbackState: BehaviorRelay<MPMusicPlaybackState> = .init(value: .stopped)

    private var isExistUser: Binder<(Service, MPMediaItem, UIImage)> {
        return .init(self) {
            if User.isExists(service: $1.0) {
                $0.router.openPostView(service: $1.0, item: $1.1, screenshot: $1.2)
            } else {
                $0.router.notExistServiceUser()
            }
        }
    }

    init(router: PlayRoutable) {
        self.router = router
        checkMediaLibraryAuthorization()

        musicPlayer.beginGeneratingPlayback().disposed(by: disposeBag)

        subscribeInputs()
        subscribeNotifications()
    }

    // MARK: - Private method

    private func subscribeInputs() {
        playPauseButtonTrigger
            .withLatestFrom(playbackState) { $1 }
            .map { $0 == .playing }
            .bind(to: musicPlayer.playing)
            .disposed(by: disposeBag)

        previousButtonTrigger.bind(to: musicPlayer.skipToPreviousItem).disposed(by: disposeBag)
        nextButtonTrigger.bind(to: musicPlayer.skipToNextItem).disposed(by: disposeBag)

        gearButtonTrigger
            .subscribe(onNext: { [unowned self] in
                self.router.openSetting()
            })
            .disposed(by: disposeBag)

        mastodonButtonTrigger
            .withLatestFrom(nowPlayingItem)
            .compactMap { $0 }
            .withLatestFrom(tookScreenshot) { ($0, $1) }
            .map { (.mastodon, $0, $1) }
            .bind(to: isExistUser)
            .disposed(by: disposeBag)

        twitterButtonTrigger
            .withLatestFrom(nowPlayingItem)
            .compactMap { $0 }
            .withLatestFrom(tookScreenshot) { ($0, $1) }
            .map { (.twitter, $0, $1) }
            .bind(to: isExistUser)
            .disposed(by: disposeBag)

        countUpTrigger
            .subscribe(onNext: {
                var count = UserDefaults.standard.integer(forKey: .appOpenCount) + 1
                defer { UserDefaults.standard.set(count, forKey: .appOpenCount) }
                if count == 15 {
                    SKStoreReviewController.requestReview()
                    count = 0
                }
            })
            .disposed(by: disposeBag)
    }

    private func checkMediaLibraryAuthorization() {
        MPMediaLibrary.rx.requestAuthorization()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (status) in
                guard let wself = self else { return }
                switch status {
                case .authorized:
                    wself.nowPlayingItem.accept(wself.musicPlayer.nowPlayingItem)
                    wself.playbackState.accept(wself.musicPlayer.playbackState)
                case .denied, .restricted:
                    self?.router.notAccessibleToMediaLibrary(status: status)
                case .notDetermined:
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

// MARK: - PlayViewModelInput

extension PlayViewModel: PlayViewModelInput {}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {}
