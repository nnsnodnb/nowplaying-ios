//
//  URL+Query.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

extension URL {

    var queryParams: [String: String] {
        var params = [String: String]()

        guard let components = URLComponents(string: absoluteString) else {
            return params
        }
        guard let queryItems = components.queryItems else { return params }

        queryItems.forEach { params[$0.name] = $0.value }

        return params
    }
}
