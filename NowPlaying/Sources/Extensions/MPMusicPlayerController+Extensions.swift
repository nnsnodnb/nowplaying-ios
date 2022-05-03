//
//  MPMusicPlayerController+Extensions.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation
import MediaPlayer
import RxSwift

// MARK: - MusicPlayerControllable
extension MPMusicPlayerController: MusicPlayerControllable {
    // MARK: - Properties
    var nowPlayingMediaItem: MediaItem? {
        return nowPlayingItem
    }
    var nowPlayingMediaItemDidChange: Observable<MediaItem?> {
        return NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .map { $0.object as? MPMusicPlayerController }
            .map { $0?.nowPlayingMediaItem }
    }

    var playbackStateDidChange: Observable<MPMusicPlaybackState> {
        return NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .map { $0.playbackState }
    }
}
