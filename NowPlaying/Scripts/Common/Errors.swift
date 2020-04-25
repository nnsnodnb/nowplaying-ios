//
//  Errors.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/25.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

enum AuthError: Error {

    case cancel
    case unknown
}

enum APIError: Error {

    case valueError
}
