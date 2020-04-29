//
//  InstanceListRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import Foundation

struct InstanceListRequest: Request {

    struct Response: Codable {

        let instances: [Instance]

        private enum CodingKeys: String, CodingKey {
            case instances
        }
    }

    let baseURL: URL = URL(string: "https://instances.social")!
    let method: HTTPMethod = .get
    let path: String = "/api/1.0/instances/list"
    let queryParameters: [String : Any]? = ["sort_by": "users", "sort_order": "desc"]
    let headerFields: [String: String] = ["Authorization": "Bearer \(Environments.mastodonInstancesApiToken)"]

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
