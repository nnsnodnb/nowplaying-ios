//
//  Enumerates.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/18.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation

enum Service: String {

    case twitter
    case mastodon

    var postTextFormatUserDefaultsKey: UserDefaultsKey {
        switch self {
        case .twitter:
            return .tweetFormat
        case .mastodon:
            return .tootFormat
        }
    }

    var withImageTypeUserDefaultsKey: UserDefaultsKey {
        switch self {
        case .twitter:
            return .tweetWithImageType
        case .mastodon:
            return .tootWithImageType
        }
    }
}

enum WithImageType: String {

    case onlyArtwork = "アートワークのみ"
    case playerScreenshot = "再生画面のスクリーンショット"
}
