//
//  ProcessInfo+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/04/14.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

typealias Environment = [String: String]

extension ProcessInfo {

    func get(forKey key: EnvironmentKey) -> String {
        return ProcessInfo.processInfo.environment[key.rawValue]!
    }
}
