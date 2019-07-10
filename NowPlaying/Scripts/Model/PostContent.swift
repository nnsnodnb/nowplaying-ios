//
//  PostContent.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import MediaPlayer
import UIKit

struct PostContent {

    let postMessage: String
    private(set) var shareImage: UIImage?
    let songTitle: String
    let artistName: String
    let service: Service
    let item: MPMediaItem?

    mutating func removeShareImage() {
        shareImage = nil
    }
}
