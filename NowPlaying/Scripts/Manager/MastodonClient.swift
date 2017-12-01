//
//  MastodonClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/12/01.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift

class MastodonClient: NSObject {

    static let shared = MastodonClient()

    fileprivate let keychain = KeychainSwift()

    func register(handler: @escaping (([String: Any]?, Error?) -> ())) {
        let parameter: [String: String] = ["client_name": "NowPlayingiOS",
                                           "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
                                           "scopes": "write",
                                           "website": "https://itunes.apple.com/jp/app/nowplaying-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%81%A0%E3%81%91%E3%81%A7%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88/id1289764391?mt=8"]

        request(UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)! + "/api/v1/apps", method: .post, parameter: parameter) { (response) in
            guard response.result.isSuccess else {
                handler(nil, response.error)
                return
            }
            let value = response.result.value as! Dictionary<String, Any>
            handler(value, nil)
        }
    }

    func login(clientID: String, clientSecret: String, username: String, password: String, handler: @escaping ((String?) -> ())) {
        let parameter: [String: String] = ["scope": "write",
                                           "client_id": clientID,
                                           "client_secret": clientSecret,
                                           "grant_type": "password",
                                           "username": username,
                                           "password": password]

        request(UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)! + "/oauth/token", method: .post, parameter: parameter) { (response) in
            guard response.result.isSuccess else {
                handler(nil)
                return
            }
            let value = response.result.value as! [String: Any]
            if let accessToken = value["access_token"] {
                handler(accessToken as? String)
            }
        }
    }

    func toot(text: String, image: UIImage, handler: @escaping ((Error?) -> ())) {

    }

    func toot(text: String, handler: @escaping ((Error?) -> ())) {
        let parameter = ["status": text]
        request(UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)! + "/api/v1/statuses", method: .post, parameter: parameter) { (response) in
            guard response.result.isSuccess else {
                handler(response.error)
                return
            }
            handler(nil)
        }
    }

    func request(_ url: String, method: HTTPMethod, parameter: Dictionary<String, Any>?, handler: @escaping ((DataResponse<Any>) -> ())) {
        var header: [String: String] = ["Content-Type": "application/json"]

        if let accessToken = keychain.get(KeychainKey.mastodonAccessToken.rawValue) {
            header["Authorization"] = "Bearer \(accessToken)"
        }

        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15

        manager.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: header)
            .responseJSON(completionHandler: { (response) in
                handler(response)
            })
    }
}
