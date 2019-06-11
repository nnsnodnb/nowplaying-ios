//
//  APIResponse.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

struct APIResponse {

    let statusCode: Int?
    let body: Parameters?

    init(from object: Data?, urlResponse: HTTPURLResponse) {
        statusCode = urlResponse.statusCode
        guard let data = object else {
            body = nil
            return
        }
        body = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters
    }
}
