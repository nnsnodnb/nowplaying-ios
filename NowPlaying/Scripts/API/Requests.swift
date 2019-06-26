//
//  Requests.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit

protocol MastodonRequest: Request {}

protocol MastodonSocialRequest: Request {}

extension MastodonSocialRequest {

    var baseURL: URL {
        return URL(string: "https://instances.social")!
    }

    var headerFields: [String: String] {
        let apiToken = ProcessInfo.processInfo.get(forKey: .mastodonInstancesApiToken)
        return [
            "Authorization": "Bearer \(apiToken)"
        ]
    }
}
