//
//  Requests.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

protocol MastodonRequest: Request {}

protocol MastodonSocialRequest: Request {}

extension MastodonSocialRequest {

    var baseURL: URL {
        return URL(string: "https://instances.social")!
    }

    var headerFields: [String: String] {
        let apiToken = Environments.mastodonInstancesApiToken
        return [
            "Authorization": "Bearer \(apiToken)"
        ]
    }
}
