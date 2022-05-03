//
//  MusicPlayerControllable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation
import MediaPlayer

protocol MusicPlayerControllable: AnyObject {
    var nowPlayingItem: MPMediaItem? { get }

    func play()
    func pause()
    func skipToNextItem()
    func skipToPreviousItem()
    func beginGeneratingPlaybackNotifications()
    func endGeneratingPlaybackNotifications()
}
