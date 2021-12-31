//
//  MusicPlayerControllable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation

protocol MusicPlayerControllable: AnyObject {

    func play()
    func pause()
    func skipToNextItem()
    func skipToPreviousItem()
    func beginGeneratingPlaybackNotifications()
    func endGeneratingPlaybackNotifications()
}
