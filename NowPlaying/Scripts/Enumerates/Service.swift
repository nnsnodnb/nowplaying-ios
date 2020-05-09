//
//  Service.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer

enum Service: String {

    case twitter
    case mastodon

    static func setPostFormat(_ service: Service, format: String) {
        let key: UserDefaults.Key = service == .twitter ? .tweetFormat : .tootFormat
        UserDefaults.standard.set(format, forKey: key)
    }

    static func getPostFormat(_ service: Service) -> String {
        let key: UserDefaults.Key = service == .twitter ? .tweetFormat : .tootFormat
        if let text = UserDefaults.standard.string(forKey: key) { return text }
        UserDefaults.standard.set(.defaultPostFormat, forKey: key)
        return .defaultPostFormat
    }

    static func getPostText(_ service: Service, item: MPMediaItem) -> String {
        return getPostFormat(service)
            .replacingOccurrences(of: "__songtitle__", with: item.title ?? "")
            .replacingOccurrences(of: "__artist__", with: item.artist ?? "")
            .replacingOccurrences(of: "__album__", with: item.albumTitle ?? "")
    }

    static func resetPostFormat(_ service: Service) {
        Service.setPostFormat(service, format: .defaultPostFormat)
    }

    var withImageKey: UserDefaults.Key {
        switch self {
        case .twitter:
            return .isWithImage
        case .mastodon:
            return .isMastodonWithImage
        }
    }

    var withImageTypeKey: UserDefaults.Key {
        switch self {
        case .twitter:
            return .tweetWithImageType
        case .mastodon:
            return .tootWithImageType
        }
    }
}
