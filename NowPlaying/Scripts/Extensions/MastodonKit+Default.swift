//
//  MastodonKit+Default.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MastodonKit

extension Client {

    static func create(baseURL: String, accessToken: String? = nil) -> Client {
        return .init(baseURL: "https://\(baseURL)", accessToken: accessToken)
    }
}

extension Clients {

    static func registerNowPlaying() -> Request<ClientApplication> {
        return register(clientName: "NowPlayingiOS", redirectURI: "nowplaying-ios-nnsnodnb://oauth_mastodon", scopes: [.read, .write], website: websiteURL)
    }
}

extension Login {

    struct OAuthParameter {
        let code: String
        let application: ClientApplication
    }

    static func oauth(_ parameter: OAuthParameter) -> Request<LoginSettings> {
        return oauth(clientID: parameter.application.clientID, clientSecret: parameter.application.clientSecret, scopes: [.read, .write],
                     redirectURI: parameter.application.redirectURI, code: parameter.code)
    }
}
