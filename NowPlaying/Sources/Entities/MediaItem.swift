//
//  MediaItem.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import MediaPlayer

struct MediaItem: Equatable {

    // MARK: - Properties
    let persistentID: MPMediaEntityPersistentID
    let item: MPMediaItem

    var title: String? { return item.title }
    var artist: String? { return item.artist }
    var artwork: MPMediaItemArtwork? { return item.artwork }

    // MARK: - Initialize
    init(item: MPMediaItem) {
        self.persistentID = item.persistentID
        self.item = item
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.item == rhs.item
    }
}
