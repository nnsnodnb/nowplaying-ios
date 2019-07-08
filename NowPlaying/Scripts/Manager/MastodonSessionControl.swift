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
import SVProgressHUD

final class MastodonSessionControl {

    private let disposeBag = DisposeBag()

    struct Secret {
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

        mutating func configureUser(_ response: MastodonVerifyCredentialsResponse) {
            userID = response.serviceID
            name = response.displayName
            screenName = response.username
            photoURL = response.avatar
        }
    }

    private lazy var secret = Secret()

    func authorize(hostname: String) -> Observable<Secret> {
        secret.setDomain(hostname)
        return .create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onError(AuthError.nullMe)
                return Disposables.create()
            }
            wself.mastodonRegisterApp(hostname)
                .bind(to: wself.mastodonAuthorize)
                .do(onNext: { (_) in
                    SVProgressHUD.show()
                })
                .bind(to: wself.mastodonGetToken)
                .bind(to: wself.mastodonVerifyCredentials)
                .subscribe(onNext: { (secret) in
                    observer.onNext(secret)
                    observer.onCompleted()
                }, onError: {
                    observer.onError($0)
                })
                .disposed(by: wself.disposeBag)
            return Disposables.create()
        }
    }

    // アプリ登録
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

    // ユーザ自身の操作による認証
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

    // 認証トークンを取得する
    private func mastodonGetToken(authorizationCode: Observable<String>) -> Observable<String> {
        return .create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onError(AuthError.nullMe)
                return Disposables.create()
            }
            authorizationCode.subscribe(onNext: {
                let inputs = MastodonGetTokenRequest.Input(hostname: wself.secret.domain, code: $0,
                                                           clientID: wself.secret.clientID, clientSecret: wself.secret.clientSecret)
                Session.shared.rx.response(MastodonGetTokenRequest(inputs: inputs))
                    .subscribe(onSuccess: {
                        wself.secret.setAccessToken($0.accessToken)
                        observer.onNext($0.accessToken)
                        observer.onCompleted()
                    }, onError: { (error) in
                        observer.onError(error)
                    })
                    .disposed(by: wself.disposeBag)
            }, onError: {
                observer.onError($0)
            })
            .disposed(by: wself.disposeBag)
            return Disposables.create()
        }
    }

    // 認証トークンを確認しユーザ情報を取得する
    private func mastodonVerifyCredentials(accessToken: Observable<String>) -> Observable<Secret> {
        return .create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onError(AuthError.nullMe)
                return Disposables.create()
            }
            accessToken.subscribe(onNext: {
                Session.shared.rx.response(MastodonVerifyCredentialsRequest(hostname: wself.secret.domain, accessToken: $0))
                    .subscribe(onSuccess: {
                        wself.secret.configureUser($0)
                        observer.onNext(wself.secret)
                        observer.onCompleted()
                    }, onError: {
                        observer.onError($0)
                    })
                    .disposed(by: wself.disposeBag)
            }, onError: {
                observer.onError($0)
            })
            .disposed(by: wself.disposeBag)
            return Disposables.create()
        }
    }
}
