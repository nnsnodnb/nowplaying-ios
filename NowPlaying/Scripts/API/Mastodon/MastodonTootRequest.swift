//
//  MastodonTootRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import KeychainAccess

struct MastodonTootRequest: MastodonRequest {

    typealias Response = Void

    private let keychain = Keychain.nowPlaying
    private let hostname = "https://\(UserDefaults.string(forKey: .mastodonHostname)!)"
    private let status: String
    private let mediaIDs: [String]?

    init(status: String, mediaIDs: [String]?=nil) {
        self.status = status
        self.mediaIDs = mediaIDs
    }

    var baseURL: URL {
        return URL(string: hostname)!
    }

    var path: String {
        return "/api/v1/statuses"
    }

    var method: HTTPMethod {
        return .post
    }

    var parameters: Any? {
        guard let mediaIDs = mediaIDs else { return ["status": status] }
        return [
            "status": status,
            "media_ids": mediaIDs
        ]
    }

    var headerFields: [String: String] {
        guard let accessToken = try? keychain.getString(KeychainKey.mastodonAccessToken.rawValue) else { return [:] }
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws {
        if !urlResponse.statusCode.isSuccessStatusCode {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
    }
}
