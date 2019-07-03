//
//  MastodonGetTokenRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct MastodonGetTokenRequest: MastodonRequest {

    typealias Response = MastodonGetTokenResponse

    struct Input {
        let hostname: String
        let code: String
        let clientID: String
        let clientSecret: String
    }

    private let hostname: String
    private let code: String
    private let clientID: String
    private let clientSecret: String

    init(inputs: Input) {
        hostname = "https://\(inputs.hostname)"
        code = inputs.code
        clientID = inputs.clientID
        clientSecret = inputs.clientSecret
    }

    var baseURL: URL {
        return URL(string: hostname)!
    }

    var path: String {
        return "/oauth/token"
    }

    var method: HTTPMethod {
        return .post
    }

    var parameters: Any? {
        return [
            "grant_type": "authorization_code",
            "redirect_uri": "nowplaying-ios-nnsnodnb://oauth_mastodon",
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> MastodonGetTokenResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonGetTokenResponse: Codable {

    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
