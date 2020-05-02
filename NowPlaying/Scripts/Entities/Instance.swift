//
//  Instance.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Differentiator
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

    static func notFound(hostname: String) -> Instance {
        return .init(instanceID: "empty_\(hostname)", name: hostname, info: .init(shortDescription: "もしかして？"), thumbnailURL: nil)
    }
}

// MARK: - Equatable

extension Instance: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.instanceID == rhs.instanceID
    }
}

// MARK: - IdentifiableType

extension Instance: IdentifiableType {

    var identity: String {
        return instanceID
    }
}

struct InstanceInfo: Codable {

    let shortDescription: String?

    private enum CodingKeys: String, CodingKey {
        case shortDescription = "short_description"
    }
}
