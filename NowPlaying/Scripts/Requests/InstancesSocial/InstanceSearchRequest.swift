//
//  InstanceSearchRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import Foundation

struct InstanceSearchRequest: InstancesSocialRequst {

    let path: String = "/api/1.0/instances/search"
    let query: String

    var queryParameters: [String: Any]? {
        return [
            "count": 20,
            "q": query,
            "name": true
        ]
    }

    init(query: String) {
        self.query = query
    }
}
