//
//  StubMediaItem.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

import Foundation
import MediaPlayer
@testable import NowPlaying

struct StubMediaItem: MediaItem {
    // MARK: - Properties
    let persistentID: MPMediaEntityPersistentID
    let title: String?
    let artist: String?
    let artwork: MPMediaItemArtwork?

    // MARK: - Initialize
    init(persistentID: MPMediaEntityPersistentID = .random(in: 1...99999),
         title: String? = nil,
         artist: String? = nil,
         artwork: MPMediaItemArtwork? = nil) {
        self.persistentID = persistentID
        self.title = title
        self.artist = artist
        self.artwork = artwork
    }
}
