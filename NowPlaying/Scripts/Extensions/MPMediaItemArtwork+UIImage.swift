//
//  MPMediaItemArtwork+UIImage.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPMediaItemArtwork {

    var image: UIImage? {
        return image(at: bounds.size)
    }
}
