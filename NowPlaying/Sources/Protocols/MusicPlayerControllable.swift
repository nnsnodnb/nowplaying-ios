//
//  MusicPlayerControllable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation
import MediaPlayer
import RxSwift

protocol MusicPlayerControllable: AnyObject {
    var nowPlayingMediaItem: MediaItem? { get }
    var playbackState: MPMusicPlaybackState { get }
    var nowPlayingMediaItemDidChange: Observable<MediaItem?> { get }
    var playbackStateDidChange: Observable<MPMusicPlaybackState> { get }

    func play()
    func pause()
    func skipToNextItem()
    func skipToPreviousItem()
    func beginGeneratingPlaybackNotifications()
    func endGeneratingPlaybackNotifications()
}
