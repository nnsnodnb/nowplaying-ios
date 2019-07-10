//
//  MastodonTootRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct MastodonTootRequest: MastodonRequest {

    typealias Response = Void

    private let secret: SecretCredential
    private let status: String
    private let mediaIDs: [String]?

    init(secret: SecretCredential, status: String, mediaIDs: [String]?=nil) {
        self.secret = secret
        self.status = status
        self.mediaIDs = mediaIDs
    }

    var baseURL: URL {
        return URL(string: "https://\(secret.domainName)")!
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
        return [
            "Authorization": "Bearer \(secret.authToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws {
        if !urlResponse.statusCode.isSuccessStatusCode {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
    }
}
