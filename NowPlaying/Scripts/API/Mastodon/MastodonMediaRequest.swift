//
//  MastodonMediaRequest.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import KeychainAccess

struct MastodonMediaRequest: MastodonRequest {

    typealias Response = MastodonMediaResponse

    private let imageData: Data
    private let fileName = "\(Date().timeIntervalSince1970).png"
    private let keychain = Keychain.nowPlaying

    init(imageData: Data) {
        self.imageData = imageData
    }

    var baseURL: URL {
        return URL(string: "https://\(UserDefaults.string(forKey: .mastodonHostname)!)")!
    }

    var path: String {
        return "/api/v1/media"
    }

    var method: HTTPMethod {
        return .post
    }

    var bodyParameters: BodyParameters? {
        let imageDataPart = MultipartFormDataBodyParameters.Part(data: imageData, name: "file", mimeType: "image/png", fileName: fileName)
        return MultipartFormDataBodyParameters(parts: [imageDataPart])
    }

    var headerFields: [String: String] {
        // FIXME: トークンの取得方法
        guard let accessToken = try? keychain.getString(KeychainKey.mastodonAccessToken.rawValue) else { return [:] }
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> MastodonMediaResponse {
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct MastodonMediaResponse: Codable {

    let mediaID: String

    private enum CodingKeys: String, CodingKey {
        case mediaID = "id"
    }
}
