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
import TwitterKit
import UIKit

struct PlayViewModelInput {

    let previousButton: Observable<Void>
    let playButton: Observable<Void>
    let nextButton: Observable<Void>
    let mastodonButton: Observable<Void>
    let twitterButton: Observable<Void>
}

// MARK: - PlayViewModelOutput

protocol PlayViewModelOutput {

    var nowPlayingItem: Driver<MPMediaItem> { get }
    var playButtonImage: Driver<UIImage?> { get }
    var loginRequired: Observable<Void> { get }
    var postContent: Driver<PostContent> { get }
    var requestDenied: Observable<Void> { get }
}

// MARK: - PlayViewModelType

protocol PlayViewModelType {

    var outputs: PlayViewModelOutput { get }
    init(inputs: PlayViewModelInput)
    func countUpOpenCount()
}

final class PlayViewModel: PlayViewModelType {

    var outputs: PlayViewModelOutput { return self }

    private let isPlaying: BehaviorRelay<Bool>
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let disposeBag = DisposeBag()
    private let _nowPlayingItem = BehaviorRelay<MPMediaItem?>(value: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
    private let loginError = PublishRelay<Void>()
    private let _postContent = PublishRelay<PostContent>()
    private let _requestDenied = PublishRelay<Void>()

    init(inputs: PlayViewModelInput) {
        isPlaying = BehaviorRelay(value: musicPlayer.playbackState == .playing)

        musicPlayer.beginGeneratingPlaybackNotifications()

        // 再生状態の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .subscribe(onNext: { [weak self] (_) in
                self?.isPlaying.accept(self?.musicPlayer.playbackState == .playing)
            })
            .disposed(by: disposeBag)

        // 再生されている曲の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .subscribe(onNext: { [weak self] (notification) in
                guard let player = notification.object as? MPMusicPlayerController else { return }
                self?._nowPlayingItem.accept(player.nowPlayingItem)
            })
            .disposed(by: disposeBag)

        MPMediaLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                Observable<Int>.timer(.milliseconds(500), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] (_) in
                        self?._nowPlayingItem.accept(self?.musicPlayer.nowPlayingItem)
                    })
                    .disposed(by: self.disposeBag)
            case .denied:
                self._requestDenied.accept(())
            case .notDetermined, .restricted:
                break
            @unknown default:
                break
            }
        }

        setupInputObserver(inputs)
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

    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }

    // MARK: - Private method

    private func setupInputObserver(_ inputs: PlayViewModelInput) {
        inputs.previousButton
            .subscribe(onNext: { () in
                MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
                Analytics.Play.previousButton()
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
                Analytics.Play.playButton(isPlaying: isPlay)
                self?.isPlaying.accept(isPlay)
            })
            .disposed(by: disposeBag)

        inputs.nextButton
            .subscribe(onNext: { (_) in
                MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
                Analytics.Play.nextButton()
            })
            .disposed(by: disposeBag)

        inputs.mastodonButton
            .subscribe(onNext: { [weak self] (_) in
                if !UserDefaults.bool(forKey: .isMastodonLogin) {
                    self?.loginError.accept(())
                    return
                }
                Analytics.Play.mastodonButton()

                self?.setNewPostContent(service: .mastodon)
            })
            .disposed(by: disposeBag)

        inputs.twitterButton
            .subscribe(onNext: { [weak self] (_) in
                if TWTRTwitter.sharedInstance().sessionStore.session() == nil {
                    self?.loginError.accept(())
                    return
                }
                Analytics.Play.twitterButton()

                self?.setNewPostContent(service: .twitter)
            })
            .disposed(by: disposeBag)
    }

    private func setNewPostContent(service: Service) {
        guard let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else {
            let post = PostContent(postMessage: "", shareImage: nil, songTitle: "", artistName: "", service: service)
            _postContent.accept(post)
            return
        }

        let postTitle = nowPlayingItem.title ?? ""
        let postArtist = nowPlayingItem.artist ?? ""
        let postText = "\(postTitle) by \(postArtist) #NowPlaying"

        let userDefaultsKey: UserDefaultsKey = service == .mastodon ? .isMastodonWithImage : .isWithImage
        if UserDefaults.bool(forKey: userDefaultsKey), let artwork = nowPlayingItem.artwork {
            let post = PostContent(postMessage: postText, shareImage: artwork.image(at: artwork.bounds.size),
                                   songTitle: postTitle, artistName: postArtist, service: service)
            _postContent.accept(post)
        } else {
            let post = PostContent(postMessage: postText, shareImage: nil, songTitle: postTitle,
                                   artistName: postArtist, service: service)
            _postContent.accept(post)
        }
    }
}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {

    var nowPlayingItem: SharedSequence<DriverSharingStrategy, MPMediaItem> {
        return _nowPlayingItem
            .compactMap { $0 }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
    }

    var playButtonImage: SharedSequence<DriverSharingStrategy, UIImage?> {
        return isPlaying
            .map { $0 ? R.image.pause() : R.image.play() }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
    }

    var loginRequired: Observable<Void> {
        return loginError.observeOn(MainScheduler.instance).asObservable()
    }

    var postContent: SharedSequence<DriverSharingStrategy, PostContent> {
        return _postContent.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var requestDenied: Observable<Void> {
        return _requestDenied.observeOn(MainScheduler.instance).asObservable()
    }
}
