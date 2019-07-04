//
//  MastodonTokenRevokeRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/07/04.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct MastodonTokenRevokeRequest: MastodonRequest {

    typealias Response = Void

    private let secret: SecretCredential

    init(secret: SecretCredential) {
        self.secret = secret
    }

    var baseURL: URL {
        return URL(string: "https://\(secret.domainName)")!
    }

    var path: String {
        return "/oauth/revoke"
    }

    var method: HTTPMethod {
        return .post
    }

    var headerFields: [String: String] {
        return [
            "Authorization": "Bearer \(secret.authToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return
    }
}
