//
//  MastodonSessionControl.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import RxCocoa
import RxSwift
import SafariServices

final class MastodonSessionControl {

    private let disposeBag = DisposeBag()

    private struct Secret {
        var userID: String = ""
        var name: String = ""
        var screenName: String = ""
        var photoURL: URL?
        private(set) var clientID: String = ""
        private(set) var clientSecret: String = ""
        private(set) var accessToken: String = ""
        private(set) var domain: String = ""

        mutating func setDomain(_ domain: String) {
            self.domain = domain
        }

        mutating func configure(_ response: MastodonAppResponse) {
            clientID = response.clientID
            clientSecret = response.clientSecret
        }

        mutating func setAccessToken(_ token: String) {
            accessToken = token
        }
    }

    private lazy var secret = Secret()

    func authorize(hostname: String) -> Observable<String> {
        secret.setDomain(hostname)
        return .create { [unowned self] (observer) -> Disposable in
            self.mastodonRegisterApp(hostname)
                .bind(to: self.mastodonAuthorize)
                .bind(to: self.mastodonGetToken)
                .bind(to: observer.asObserver())
                .disposed(by: self.disposeBag)
            // TODO: Firebase Auth & Firebase RealDatabase

            return Disposables.create()
        }
    }

    private func mastodonRegisterApp(_ hostname: String) -> Observable<URL> {
        return .create { [unowned self] (observer) -> Disposable in
            Session.shared.rx.response(MastodonAppRequest(hostname: hostname))
                .subscribe(onSuccess: { (response) in
                    let url = URL(string: "https://\(response.host)/oauth/authorize")!
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: url.baseURL != nil)
                    components?.queryItems = [
                        .init(name: "client_id", value: response.clientID),
                        .init(name: "response_type", value: "code"),
                        .init(name: "redirect_uri", value: response.redirectURI),
                        .init(name: "scope", value: "read write")
                    ]
                    self.secret.configure(response)
                    guard let authorizeURL = components?.url else {
                        observer.onError(AuthError.internalError)
                        return
                    }
                    print("🔎 \(authorizeURL.absoluteString)")
                    observer.onNext(authorizeURL)
                    observer.onCompleted()
                }, onError: { (error) in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    private func mastodonAuthorize(url: Observable<URL>) -> Observable<String> {
        var session: SFAuthenticationSession?
        return .create { [unowned self] (observer) -> Disposable in
            url.subscribe(onNext: { (url) in
                session = SFAuthenticationSession(url: url, callbackURLScheme: "nowplaying-ios-nnsnodnb") { (url, error) in
                    guard let url = url else {
                        observer.onError(error!)
                        return
                    }
                    guard let query = (url as NSURL).uq_queryDictionary(), let code = query["code"] as? String else {
                        observer.onError(AuthError.nullAccessToken)
                        return
                    }
                    observer.onNext(code)
                    observer.onCompleted()
                }
                session?.start()
            }, onError: { (error) in
                observer.onError(error)
            })
            .disposed(by: self.disposeBag)
            return Disposables.create { session?.cancel() }
        }
    }

    private func mastodonGetToken(authorizationCode: Observable<String>) -> Observable<String> {
        return .create { [unowned self] (observer) -> Disposable in
            authorizationCode.subscribe(onNext: {
                let inputs: MastodonGetTokenRequest.Input = .init(hostname: self.secret.domain, code: $0,
                                                                  clientID: self.secret.clientID, clientSecret: self.secret.clientSecret)
                Session.shared.rx.response(MastodonGetTokenRequest(inputs: inputs))
                    .subscribe(onSuccess: { [weak self] (response) in
                        self?.secret.setAccessToken(response.accessToken)
                        observer.onNext(response.accessToken)
                        observer.onCompleted()
                    }, onError: { (error) in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }, onError: {
                observer.onError($0)
            })
            .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    private func mastodonGetAccountDetail(userID: Observable<String>) -> Observable<MastodonAccountsResponse> {
        return .create { (observer) -> Disposable in
            return Disposables.create()
        }
    }
}
