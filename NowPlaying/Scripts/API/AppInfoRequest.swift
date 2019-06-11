//
//  AppInfoRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation

struct AppInfoRequest: Request {

    typealias Response = AppInfoResponse

    var baseURL: URL {
        return URL(string: "https://nowplayingios.firebaseapp.com")!
    }

    var path: String {
        return "/app_info.json"
    }

    var method: HTTPMethod {
        return .get
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> AppInfoResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct AppInfoResponse: Codable {

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
