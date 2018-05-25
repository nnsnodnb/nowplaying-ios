//
//  HTTPURLResponse+StatusCode.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

extension Int {

    var isSuccessStatusCode: Bool {
        return self >= 200 && self < 300
    }
}
