//
//  AppInfoManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import Result

class AppInfoManager {

    static var session: URLSession {
        let sessionConfigure = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfigure)
    }

    class func getAppInfo(handler: @escaping (APIResult) -> Void) {
        guard let url = URL(string: "https://nowplayingios.firebaseapp.com/app_info.json") else { return }
        let task = AppInfoManager.session.dataTask(with: url) { (data, response, error) in
            if let data = data, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode.isSuccessStatusCode {
                handler(APIResult(value: APIResponse(from: data, urlResponse: urlResponse)))
            } else {
                let error = error ?? NSError(domain: "APIRequestError", code: 2, userInfo: nil)
                handler(APIResult(error: AnyError(error)))
            }
        }
        task.resume()
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
