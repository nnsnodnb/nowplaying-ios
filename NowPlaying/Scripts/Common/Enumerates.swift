//
//  Enumerates.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/18.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation

enum Service {

    case twitter
    case mastodon
}

enum WithImageType: String {

    case onlyArtwork = "アートワークのみ"
    case playerScreenshot = "再生画面のスクリーンショット"
}
