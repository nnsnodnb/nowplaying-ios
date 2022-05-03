//
//  MediaItem.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import MediaPlayer

protocol MediaItem {
    var persistentID: MPMediaEntityPersistentID { get }
    var title: String? { get }
    var artist: String? { get }
    var artwork: MPMediaItemArtwork? { get }
}

extension MPMediaItem: MediaItem {}
