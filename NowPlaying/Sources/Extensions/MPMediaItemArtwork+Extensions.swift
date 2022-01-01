//
//  MPMediaItemArtwork+Extensions.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation
import MediaPlayer

extension MPMediaItemArtwork {
    var image: UIImage? {
        return image(at: bounds.size)
    }
}
