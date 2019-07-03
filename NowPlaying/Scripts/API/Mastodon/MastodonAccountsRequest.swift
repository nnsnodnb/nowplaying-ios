//
//  MastodonAccountsRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import KeychainAccess
import UIKit

struct MastodonAccountsRequest: MastodonRequest {

    typealias Response = MastodonAccountsResponse

    private let keychain = Keychain.nowPlaying
    private let hostname: String
    private let userID: String

    var baseURL: URL {
        return URL(string: "https://\(hostname)")!
    }

    var path: String {
        return "/api/v1/accounts/\(userID)"
    }

    var method: HTTPMethod {
        return .get
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

struct MastodonAccountsResponse: Codable {

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
