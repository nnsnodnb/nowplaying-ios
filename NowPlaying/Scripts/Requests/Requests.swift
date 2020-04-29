//
//  Requests.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import Foundation

protocol InstancesSocialRequst: Request {}

extension InstancesSocialRequst {

    var baseURL: URL { return URL(string: "https://instances.social")! }
    var method: HTTPMethod { return .get }
    var headerFields: [String: String] { return ["Authorization": "Bearer \(Environments.mastodonInstancesApiToken)"] }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 20
        return urlRequest
    }
}

extension InstancesSocialRequst where Response: Codable {

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
