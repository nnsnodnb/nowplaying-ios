//
//  SFAuthenticationSession+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MastodonKit
import RxCocoa
import RxSwift
import SafariServices

struct OAuth2Parameter {

    let url: URL
    let callbackURLScheme: String?
}

extension Reactive where Base == SFAuthenticationSession {

    static func authorize(hostname: String, application: ClientApplication) -> Single<String> {
        return .create { (observer) -> Disposable in
            let url = URL(string: "\(hostname)/oauth/authorize")!
            var components = URLComponents(url: url, resolvingAgainstBaseURL: url.baseURL != nil)
            components?.queryItems = [
                .init(name: "client_id", value: application.clientID),
                .init(name: "response_type", value: "code"),
                .init(name: "redirect_uri", value: application.redirectURI),
                .init(name: "scope", value: "read write")
            ]
            guard let authorizeURL = components?.url else {
                observer(.error(AuthError.unknown))
                return Disposables.create()
            }

            let session = SFAuthenticationSession(url: authorizeURL, callbackURLScheme: "nowplaying-ios-nnsnodnb") { (url, error) in
                guard let url = url, error == nil else {
                    return observer(.error(error!))
                }
                guard let code = url.queryParams["code"] else {
                    return observer(.error(AuthError.unknown))
                }
                observer(.success(code))
            }
            session.start()

            return Disposables.create {
                session.cancel()
            }
        }
    }
}
