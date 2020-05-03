//
//  Service.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

enum Service: String {

    case twitter
    case mastodon

    static func setPostFormat(_ service: Service, format: String) {
        switch service {
        case .twitter:
            UserDefaults.standard.set(format, forKey: .tweetFormat)
        case .mastodon:
            UserDefaults.standard.set(format, forKey: .tootFormat)
        }
    }

    static func getPostFormat(_ service: Service) -> String {
        switch service {
        case .twitter:
            if let text = UserDefaults.standard.string(forKey: .tweetFormat) {
                return text
            }
            UserDefaults.standard.set(.defaultPostFormat, forKey: .tweetFormat)
            return .defaultPostFormat

        case .mastodon:
            if let text = UserDefaults.standard.string(forKey: .tootFormat) {
                return text
            }
            UserDefaults.standard.set(.defaultPostFormat, forKey: .tootFormat)
            return .defaultPostFormat
        }
    }

    static func resetPostFormat(_ service: Service) {
        Service.setPostFormat(service, format: .defaultPostFormat)
    }
}
