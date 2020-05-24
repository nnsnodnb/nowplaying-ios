//
//  NowPlayingAppInfoRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/24.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import Foundation

struct NowPlayingAppInfoRequest: Request {

    struct Response: Codable {

        let appVersion: AppVersion

        private enum CodingKeys: String, CodingKey {
            case appVersion = "app_version"
        }
    }

    struct AppVersion: Codable {

        let require: String
        let latest: String

        private enum CodingKeys: String, CodingKey {
            case require
            case latest
        }
    }

    let baseURL: URL = URL(string: "https://nnsnodnb.github.io/nowplaying-ios/")!
    let method: HTTPMethod = .get
    let path: String = "app_info.json"

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
