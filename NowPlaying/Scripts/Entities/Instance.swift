//
//  Instance.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

struct Instance: Codable {

    let instanceID: String
    let name: String
    let info: InstanceInfo?
    let thumbnailURL: URL?

    private enum CodingKeys: String, CodingKey {
        case instanceID = "id"
        case name
        case info
        case thumbnailURL = "thumbnail"
    }
}

struct InstanceInfo: Codable {

    let shortDescription: String?

    private enum CodingKeys: String, CodingKey {
        case shortDescription = "short_description"
    }
}
