//
//  InstanceListRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import Foundation

struct InstanceListRequest: InstancesSocialRequst {

    let path: String = "/api/1.0/instances/list"
    let queryParameters: [String: Any]? = ["sort_by": "users", "sort_order": "desc"]
}
