//
//  InstancesSearchRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct InstancesSearchRequest: Request {

    typealias Response = InstanceSearchResponse

    private let count: Int
    private let query: String
    private let name: Bool

    init(count: Int = 20, query: String, name: Bool = true) {
        self.count = count
        self.query = query
        self.name = name
    }

    var baseURL: URL {
        return URL(string: "https://instances.social")!
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

    var headerFields: [String: String] {
        let apiToken = ProcessInfo.processInfo.get(forKey: .mastodonInstancesApiToken)
        return [
            "Authorization": "Bearer \(apiToken)"
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

struct Instance: Codable {

    let instanceID: String
    let name: String
    let info: InstanceInfo
    let thumbnailURL: URL

    private enum CodingKeys: String, CodingKey {
        case instanceID = "id"
        case name
        case info
        case thumbnailURL = "thumbnail"
    }
}

struct InstanceInfo: Codable {

    let shortDescription: String

    private enum CodingKeys: String, CodingKey {
        case shortDescription = "short_description"
    }
}
