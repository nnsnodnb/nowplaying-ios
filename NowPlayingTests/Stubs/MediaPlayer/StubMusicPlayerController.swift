//
//  StubMusicPlayerController.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

import Foundation
import MediaPlayer
@testable import NowPlaying
import RxCocoa
import RxSwift

final class StubMusicPlayerController: MusicPlayerControllable {
    // MARK: - Properties
    var nowPlayingMediaItem: MediaItem?
    var playbackState: MPMusicPlaybackState
    var nowPlayingMediaItemDidChange: Observable<MediaItem?>
    var playbackStateDidChange: Observable<MPMusicPlaybackState>

    private let mediaItem: BehaviorRelay<MediaItem?>
    private let _playbackState: BehaviorRelay<MPMusicPlaybackState>

    // MARK: - Initialize
    init(mediaItem: MediaItem?, playbackState: MPMusicPlaybackState) {
        self.nowPlayingMediaItem = mediaItem
        self.mediaItem = .init(value: mediaItem)
        self.playbackState = playbackState
        self.nowPlayingMediaItemDidChange = self.mediaItem.asObservable()
        self._playbackState = .init(value: playbackState)
        self.playbackStateDidChange = _playbackState.distinctUntilChanged()
    }

    func play() {
        _playbackState.accept(.playing)
    }

    func pause() {
        _playbackState.accept(.paused)
    }

    func skipToNextItem() {
        let size = CGSize(width: 1, height: 1)
        let artwork = MPMediaItemArtwork(boundsSize: size) { _ in Asset.Assets.icMusic.image }
        mediaItem.accept(StubMediaItem(title: "next item", artist: "next artist", artwork: artwork))
    }

    func skipToPreviousItem() {
        let size = CGSize(width: 1, height: 1)
        let artwork = MPMediaItemArtwork(boundsSize: size) { _ in Asset.Assets.icMusic.image }
        mediaItem.accept(StubMediaItem(title: "previous item", artist: "previous artist", artwork: artwork))
    }

    func beginGeneratingPlaybackNotifications() {}

    func endGeneratingPlaybackNotifications() {}
}
