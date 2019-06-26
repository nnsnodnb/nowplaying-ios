//
//  InstanceListRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/26.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct InstanceListRequest: MastodonSocialRequest {

    typealias Response = InstanceListResponse

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/1.0/instances/list"
    }

    var queryParameters: [String: Any]? {
        return [
            "sort_by": "users",
            "sort_order": "desc"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> InstanceListResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct InstanceListResponse: Codable {

    let instances: [Instance]

    private enum CodingKeys: String, CodingKey {
        case instances
    }
}
