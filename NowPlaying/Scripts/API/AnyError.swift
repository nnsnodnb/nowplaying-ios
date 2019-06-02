//
//  AnyError.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation

struct AnyError: Error {

    let error: Error

    init(error: Error) {
        self.error = error
    }
}
