//
//  MastodonRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/27.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import KeychainAccess

class MastodonRequest: RequestFactory {

    let keychain = Keychain(service: keychainServiceKey)

    class Register: MastodonRequest {
        private let clientName: String = "NowPlayingiOS"
        private let redirectURI = "nowplaying-ios-nnsnodnb://oauth_mastodon"
        private let scopes = "write"

        override var url: URL {
            var baseURL = URL(string: UserDefaults.string(forKey: .mastodonHostname)!)!
            baseURL.appendPathComponent("api/v1/apps")
            return baseURL
        }

        override var method: HTTPMethod {
            return .post
        }

        override var dictionary: Parameters {
            return [
                "client_name": clientName,
                "redirect_uris": redirectURI,
                "scopes": scopes,
                "website": websiteUrl
            ]
        }
    }

    class GetToken: MastodonRequest {
        private let code: String
        private let clientID = UserDefaults.string(forKey: .mastodonClientID)!
        private let clientSecret = UserDefaults.string(forKey: .mastodonClientSecret)!

        init(code: String) {
            self.code = code
        }

        override var url: URL {
            var baseURL = URL(string: UserDefaults.string(forKey: .mastodonHostname)!)!
            baseURL.appendPathComponent("oauth/token")
            return baseURL
        }

        override var method: HTTPMethod {
            return .post
        }

        override var dictionary: Parameters {
            return [
                "grant_type": "authorization_code",
                "redirect_uri": "nowplaying-ios-nnsnodnb://oauth_mastodon",
                "client_id": clientID,
                "client_secret": clientSecret,
                "code": code
            ]
        }
    }

    class Toot: MastodonRequest {

        override var session: URLSession {
            let sessionConfigure = URLSessionConfiguration.default
            let accessToken = try? keychain.get(KeychainKey.mastodonAccessToken.rawValue) ?? ""
            sessionConfigure.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken ?? "")",
                "Content-type": "application/json"
            ]
            return URLSession(configuration: sessionConfigure)
        }

        private let status: String

        init(status: String) {
            self.status = status
        }

        override var url: URL {
            var baseURL = URL(string: UserDefaults.string(forKey: .mastodonHostname)!)!
            baseURL.appendPathComponent("api/v1/statuses")
            return baseURL
        }

        override var method: HTTPMethod {
            return .post
        }

        override var dictionary: Parameters {
            return [
                "status": status
            ]
        }
    }
}
