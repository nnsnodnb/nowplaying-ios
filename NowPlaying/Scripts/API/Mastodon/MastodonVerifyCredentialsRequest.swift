//
//  MastodonVerifyCredentialsRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import KeychainAccess
import UIKit

struct MastodonVerifyCredentialsRequest: MastodonRequest {

    typealias Response = MastodonVerifyCredentialsResponse

    private let keychain = Keychain.nowPlaying
    private let hostname: String
    private let accessToken: String

    init(hostname: String, accessToken: String) {
        self.hostname = hostname
        self.accessToken = accessToken
    }

    var baseURL: URL {
        return URL(string: "https://\(hostname)")!
    }

    var path: String {
        return "/api/v1/accounts/verify_credentials"
    }

    var method: HTTPMethod {
        return .get
    }

    var headerFields: [String: String] {
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonVerifyCredentialsResponse: Codable {

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
