//
//  Responses.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

struct InstanceResponse: Codable {

    let instances: [Instance]

    private enum CodingKeys: String, CodingKey {
        case instances
    }
}
