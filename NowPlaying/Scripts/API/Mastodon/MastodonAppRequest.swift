//
//  MastodonAppRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct MastodonAppRequest: MastodonRequest {

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
            "scopes": "read write",
            "website": websiteURL
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> MastodonAppResponse {
        guard var object = object as? [String: Any] else {
            throw NSError(domain: "moe.nnsnodnb.NowPlaying", code: 400, userInfo: ["detail": "object is not dictionary."])
        }
        object["host"] = urlResponse.url?.host ?? ""
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonAppResponse: Codable {

    let name: String
    let id: String
    let redirectURI: String
    let website: URL
    let clientID: String
    let clientSecret: String
    let host: String

    private enum CodingKeys: String, CodingKey {
        case name
        case id
        case redirectURI = "redirect_uri"
        case website
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case host
    }
}
