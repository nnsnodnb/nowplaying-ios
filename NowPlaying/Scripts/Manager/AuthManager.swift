//
//  AuthManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/18.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import FirebaseAuth
import FirebaseDatabase
import KeychainAccess
import RxSwift
import SafariServices
import SwifteriOS
import UIKit

final class AuthManager: NSObject {

    private let disposeBag = DisposeBag()
    private let keychain = Keychain.nowPlaying
    private let authService: AuthService

    enum AuthService: Equatable {
        case twitter
        case mastodon(String)
    }

    enum AuthError: Swift.Error {
        case nullAccessToken
        case internalError
        case nullMe
    }

    init(authService: AuthService) {
        self.authService = authService
    }

    struct LoginCallback {

        let userID: String
        let name: String
        let screenName: String
        let photoURL: URL
        let accessToken: String
        let accessTokenSecret: String
    }
}

// MARK: - Twitter

extension AuthManager {

    func twitterLogin(presenting: UIViewController) -> Observable<LoginCallback> {
        if authService != .twitter { return .error(AuthError.internalError) }
        return .create { (observer) -> Disposable in
            let callbackURL = URL(string: "nowplaying-ios-nnsnodnb://twitter/oauth/success")!
            let swifter = Swifter(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret)
            swifter.authorize(
                withCallback: callbackURL, presentingFrom: presenting, safariDelegate: presenting as? SFSafariViewControllerDelegate,
                success: { (accessToken, _) in
                    guard let accessToken = accessToken else {
                        observer.onError(AuthError.nullAccessToken)
                        return
                    }
                    // Firebase Auth
                    let credential = TwitterAuthProvider.credential(withToken: accessToken.key, secret: accessToken.secret)
                    Auth.auth().signIn(with: credential) { (authDataResult, error) in
                        guard let authDataResult = authDataResult, error == nil else {
                            observer.onError(error!)
                            return
                        }
                        let name: String = authDataResult.additionalUserInfo?.profile?["name"] as? String ?? authDataResult.user.displayName ?? ""
                        DispatchQueue.global(qos: .utility).async {
                            Database.database().reference(withPath: "twitter").child(authDataResult.user.uid)
                                .setValue(
                                    [
                                        "display_name": name,
                                        "name": accessToken.screenName!,
                                        "user_id": accessToken.userID!
                                    ]
                                )
                        }
                        let profileImageURLHttps = authDataResult.additionalUserInfo?.profile?["profile_image_url_https"] as? String ?? ""
                        let photoURL = URL(string: profileImageURLHttps.replacingOccurrences(of: "_normal", with: ""))!

                        let callback = LoginCallback(userID: accessToken.userID!, name: name, screenName: accessToken.screenName!,
                                                     photoURL: photoURL, accessToken: accessToken.key, accessTokenSecret: accessToken.secret)
                        observer.onNext(callback)
                        observer.onCompleted()
                    }
            }, failure: {
                observer.onError($0)
            })
            return Disposables.create()
        }
    }
}

// MARK: - Mastodon

extension AuthManager {

    func mastodonLogin() -> Observable<String> {
        switch authService {
        case .twitter:
            return .error(AuthError.internalError)
        case .mastodon(let hostname):
            return .create { [weak self] (observer) -> Disposable in
                guard let wself = self else {
                    observer.onError(AuthError.nullMe)
                    return Disposables.create()
                }
                wself.mastodonRegisterApp(hostname)
                    .bind(to: wself.mastodonAuthorize)
                    .bind(to: wself.mastodonGetToken)
                    .bind(to: observer.asObserver())
                    .disposed(by: wself.disposeBag)
                // TODO: Firebase Auth & Firebase RealDatabase

                return Disposables.create()
            }
        }
    }

    private func mastodonRegisterApp(_ hostname: String) -> Observable<URL> {
        return .create { [unowned self] (observer) -> Disposable in
            Session.shared.rx.response(MastodonAppRequest(hostname: hostname))
                .subscribe(onSuccess: { (response) in
                    let url = URL(string: "https://\(response.host)")!
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: url.baseURL != nil)
                    components?.queryItems = [
                        .init(name: "client_id", value: response.clientID),
                        .init(name: "client_secret", value: response.clientSecret),
                        .init(name: "redirect_uri", value: response.redirectURI),
                        .init(name: "scopes", value: "read write")
                    ]
                    guard let authorizeURL = components?.url else {
                        observer.onError(AuthError.internalError)
                        return
                    }
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
        var session: SFAuthenticationSession!
        return .create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onError(AuthError.nullMe)
                return Disposables.create()
            }
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
            }, onError: { (error) in
                observer.onError(error)
            })
            .disposed(by: wself.disposeBag)
            return Disposables.create { session.cancel() }
        }
    }

    private func mastodonGetToken(authorizationCode: Observable<String>) -> Observable<String> {
        return .create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onError(AuthError.nullMe)
                return Disposables.create()
            }
            switch wself.authService {
            case .twitter:
                observer.onError(AuthError.internalError)
                return Disposables.create()
            case .mastodon(let hostname):
                authorizationCode.subscribe(onNext: {
                    Session.shared.rx.response(MastodonGetTokenRequest(hostname: hostname, code: $0))
                        .subscribe(onSuccess: { (response) in
                            observer.onNext(response.accessToken)
                            observer.onCompleted()
                        }, onError: { (error) in
                            observer.onError(error)
                        })
                        .disposed(by: wself.disposeBag)
                }, onError: {
                    observer.onError($0)
                })
                .disposed(by: wself.disposeBag)
            }
            return Disposables.create()
        }
    }
}

// MARK: - Deprecated

extension AuthManager {

    @available(iOS, deprecated: 2.3.1)
    func logout(completion: () -> Void) {
        try? Auth.auth().signOut()
        // FIXME: Twitterログアウト実装
//        TWTRTwitter.sharedInstance().sessionStore.logOutUserID(TWTRTwitter.sharedInstance().sessionStore.session()!.userID)
        keychain[.authToken] = nil
        keychain[.authTokenSecret] = nil
        completion()
    }

    @available(iOS, deprecated: 2.3.1)
    @discardableResult
    func mastodonLogout() -> Bool {
        do {
            try keychain.remove(.mastodonAccessToken)
            return true
        } catch {
            return false
        }
    }
}
