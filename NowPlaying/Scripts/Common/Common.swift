//
//  Common.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/23.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case isWithImage = "is_with_image"
    case isAutoTweet = "is_auto_tweet"
}

enum KeychainKey: String {
    case authToken = "authToken"
    case authTokenSecret = "authTokenSecret"
}
