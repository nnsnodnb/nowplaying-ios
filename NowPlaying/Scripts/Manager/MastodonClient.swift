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
    fileprivate let baseUrl = UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)!

    func register(handler: @escaping (([String: Any]?, Error?) -> ())) {
        // 重複登録防止
        if let clientID = keychain.get(KeychainKey.mastodonClientID.rawValue), let clientSecret = keychain.get(KeychainKey.mastodonClientSecret.rawValue) {
            let responseJson = [
                "client_id": clientID,
                "client_secret": clientSecret
            ]
            handler(responseJson, nil)
            return
        }
        let parameter: [String: String] = ["client_name": "NowPlayingiOS",
                                           "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
                                           "scopes": "write",
                                           "website": websiteUrl]

        request(baseUrl + "/api/v1/apps", method: .post, parameter: parameter) { (response) in
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

        request(baseUrl + "/oauth/token", method: .post, parameter: parameter) { (response) in
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

    func toot(text: String, image: UIImage?, handler: @escaping ((Error?) -> ())) {

    }

    func toot(text: String, handler: @escaping ((Error?) -> ())) {
        let parameter = ["status": text]
        request(baseUrl + "/api/v1/statuses", method: .post, parameter: parameter) { (response) in
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
