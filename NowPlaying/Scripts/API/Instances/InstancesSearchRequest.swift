//
//  InstancesSearchRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct InstancesSearchRequest: MastodonSocialRequest {

    typealias Response = InstanceSearchResponse

    private let count: Int
    private let query: String
    private let name: Bool

    init(count: Int = 20, query: String, name: Bool = true) {
        self.count = count
        self.query = query
        self.name = name
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/1.0/instances/search"
    }

    var queryParameters: [String: Any]? {
        return [
            "count": count,
            "q": query,
            "name": name
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> InstanceSearchResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct InstanceSearchResponse: Codable {

    let instances: [Instance]

    private enum CodingKeys: String, CodingKey {
        case instances
    }
}
