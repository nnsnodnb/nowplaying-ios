//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift
import SFSafeSymbols

protocol PlayViewModelInputs: AnyObject {
    var playPause: PublishRelay<Void> { get }
    var back: PublishRelay<Void> { get }
    var forward: PublishRelay<Void> { get }
    var mastodon: PublishRelay<Void> { get }
    var twitter: PublishRelay<Void> { get }
}

protocol PlayViewModelOutputs: AnyObject {
    var router: PlayerRoutable { get }
    var artworkImage: Driver<UIImage> { get }
    var artworkScale: Driver<CGFloat> { get }
    var songName: Driver<String> { get }
    var artistName: Driver<String> { get }
    var playPauseImage: Driver<UIImage> { get }
}

protocol PlayViewModelType: AnyObject {
    var inputs: PlayViewModelInputs { get }
    var outputs: PlayViewModelOutputs { get }
}

final class PlayViewModel: PlayViewModelType {
    // MARK: - Inputs Sources
    let playPause: PublishRelay<Void> = .init()
    let back: PublishRelay<Void> = .init()
    let forward: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<Void> = .init()
    let twitter: PublishRelay<Void> = .init()
    // MARK: - Outputs Sources
    let router: PlayerRoutable
    let artworkImage: Driver<UIImage>
    let artworkScale: Driver<CGFloat>
    let songName: Driver<String>
    let artistName: Driver<String>
    let playPauseImage: Driver<UIImage>
    // MARK: - Properties
    var inputs: PlayViewModelInputs { return self }
    var outputs: PlayViewModelOutputs { return self }

    private let disposeBag = DisposeBag()
    private let musicPlayerController: MusicPlayerControllable
    private let nowPlayingItem: BehaviorRelay<MediaItem?> = .init(value: nil)
    private let playbackState: BehaviorRelay<MPMusicPlaybackState> = .init(value: .paused)

    // MARK: - Initialize
    init(router: PlayerRoutable, musicPlayerController: MusicPlayerControllable = MPMusicPlayerController.systemMusicPlayer) {
        self.router = router
        self.musicPlayerController = musicPlayerController
        // アートワーク
        self.artworkImage = nowPlayingItem
            .map { $0?.artwork?.image ?? Asset.Assets.icMusic.image }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        self.artworkScale = playbackState
            .map { $0 == .playing ? 1 : 0.9 }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        // 曲名
        self.songName = nowPlayingItem.map { $0?.title ?? "" }.distinctUntilChanged().asDriver(onErrorDriveWith: .empty())
        // アーティスト名
        self.artistName = nowPlayingItem.map { $0?.artist ?? "" }.distinctUntilChanged().asDriver(onErrorDriveWith: .empty())
        // 再生・一時停止
        self.playPauseImage = playbackState
            .map { $0 == .playing ? .init(systemSymbol: .pauseFill) : .init(systemSymbol: .playFill) }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        playPause.asObservable()
            .withLatestFrom(playbackState)
            .subscribe(onNext: {
                if $0 == .playing {
                    musicPlayerController.pause()
                } else {
                    musicPlayerController.play()
                }
            })
            .disposed(by: disposeBag)
        // 戻る
        back.asObservable()
            .subscribe(onNext: {
                musicPlayerController.skipToPreviousItem()
            })
            .disposed(by: disposeBag)
        // 進む
        forward.asObservable()
            .subscribe(onNext: {
                musicPlayerController.skipToNextItem()
            })
            .disposed(by: disposeBag)
        // Mastodonボタン
        // Twitterボタン
        // 曲の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { musicPlayerController -> MediaItem? in
                guard let nowPlayingItem = musicPlayerController.nowPlayingItem else { return nil }
                return MediaItem(item: nowPlayingItem)
            }
            .bind(to: nowPlayingItem)
            .disposed(by: disposeBag)
        // 再生状態の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { $0.playbackState }
            .bind(to: playbackState)
            .disposed(by: disposeBag)
        musicPlayerController.beginGeneratingPlaybackNotifications()
    }

    deinit {
        musicPlayerController.endGeneratingPlaybackNotifications()
    }
}

// MARK: - PlayViewModelInputs
extension PlayViewModel: PlayViewModelInputs {}

// MARK: - PlayViewModelOutputs
extension PlayViewModel: PlayViewModelOutputs {}
