//
//  MPMediaItemArtwork+UIImage.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2020/05/17.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MediaPlayer
import UIKit

extension MPMediaItemArtwork {

    var image: UIImage? {
        return image(at: bounds.size)
    }
}
