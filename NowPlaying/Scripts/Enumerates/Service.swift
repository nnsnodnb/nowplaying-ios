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
        let key: UserDefaults.Key = service == .twitter ? .tweetFormat : .tootFormat
        UserDefaults.standard.set(format, forKey: key)
    }

    static func getPostFormat(_ service: Service) -> String {
        let key: UserDefaults.Key = service == .twitter ? .tweetFormat : .tootFormat
        if let text = UserDefaults.standard.string(forKey: key) { return text }
        UserDefaults.standard.set(.defaultPostFormat, forKey: key)
        return .defaultPostFormat
    }

    static func resetPostFormat(_ service: Service) {
        Service.setPostFormat(service, format: .defaultPostFormat)
    }
}
