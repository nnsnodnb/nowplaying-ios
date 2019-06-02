//
//  AppInfoManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

class AppInfoManager: RequestFactory {

    override var url: URL {
        return URL(string: "https://nowplayingios.firebaseapp.com/app_info.json")!
    }

    class func parseStringVersion(from versionString: String) -> (Int, Int, Int) {
        let versions = versionString.split(separator: ".")
        guard let major = Int(versions[0]), let minor = Int(versions[1]), let revision = Int(versions[2]) else {
            return (0, 0, 0)
        }
        return (major, minor, revision)
    }

    class func checkLargeVersion(current: String, target: String) -> Bool {
        let current = parseStringVersion(from: current)
        let target = parseStringVersion(from: target)

        // メジャーバージョンが小さい
        if target.0 > current.0 { return false }
        // メジャーバージョンが同じ、マイナーバージョンが小さい
        if target.0 == current.0 && target.1 > current.1 { return false }
        // メジャー、マイナーバージョンが同じ、リビジョンが小さい
        if target.0 == current.0 && target.1 == current.1 && target.2 > current.2 { return false }

        return true
    }
}
