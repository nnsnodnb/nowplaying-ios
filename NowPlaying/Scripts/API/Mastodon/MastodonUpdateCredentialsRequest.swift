//
//  MastodonVerifyCredentialsRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import KeychainAccess

struct MastodonUpdateCredentialsRequest: MastodonRequest {

    typealias Response = MastodonUpdateCredentialsResponse

    private let hostname: String
    private let keychain = Keychain.nowPlaying

    init(hostname: String) {
        self.hostname = "https://\(hostname)"
    }

    var baseURL: URL {
        return URL(string: hostname)!
    }

    var path: String {
        return "/api/v1/accounts/update_credentials"
    }

    var method: HTTPMethod {
        return .patch
    }

    var headerFields: [String: String] {
        guard let accessToken = keychain[.mastodonAccessToken] else { return [:] }
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonUpdateCredentialsResponse: Codable {

    let serviceID: String
    let username: String
    let displayName: String
    let avatar: URL

    private enum CodingKeys: String, CodingKey {
        case serviceID = "id"
        case username
        case displayName = "display_name"
        case avatar
    }
}
