//
//  MastodonAppRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct MastodonAppRequeset: MastodonRequest {

    typealias Response = MastodonAppResponse

    private let hostname: String

    init(hostname: String) {
        self.hostname = "https://\(hostname)"
    }

    var baseURL: URL {
        return URL(string: hostname)!
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/api/v1/apps"
    }

    var parameters: Any? {
        return [
            "client_name": "NowPlayingiOS",
            "redirect_uris": "nowplaying-ios-nnsnodnb://oauth_mastodon",
            "scopes": "write",
            "website": websiteURL
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> MastodonAppResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonAppResponse: Codable {

    let clientID: String
    let clientSecret: String

    private enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case clientSecret = "client_secret"
    }
}
