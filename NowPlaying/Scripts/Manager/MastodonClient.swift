//
//  MastodonClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/12/01.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation
import Alamofire

class MastodonClient: NSObject {

    static let shared = MastodonClient()

    func register(handler: @escaping (([String: Any]?, Error?) -> ())) {
        let parameter: [String: String] = ["client_name": "NowPlayingiOS",
                                           "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
                                           "scopes": "write",
                                           "website": UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)!]

        request(UserDefaults.standard.string(forKey: UserDefaultsKey.mastodonHostname.rawValue)! + "/api/v1/apps", method: .post, parameter: parameter) { (response) in
            guard response.response != nil else {
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
            guard response.error?.localizedDescription == nil else {
                handler(nil)
                return
            }
            let value = response.result.value as! [String: Any]
            if let accessToken = value["access_token"] {
                handler(accessToken as? String)
            }
        }
    }

    func request(_ url: String, method: HTTPMethod, parameter: Dictionary<String, Any>?, handler: @escaping ((DataResponse<Any>) -> ())) {
        var header: [String: String] = ["Content-Type": "application/json"]

        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
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
