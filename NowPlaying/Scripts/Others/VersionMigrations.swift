//
//  VersionMigrations.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import KeychainAccess
import RealmSwift
import RxSwift
import TwitterKit

final class VersionMigrations {

    enum Version {
        case singleAccountToMultiAccounts
    }

    static let shared = VersionMigrations()

    private let disposeBag = DisposeBag()

    func migrations(version: Version) {
        var tasks = [Observable<Void>]()
        // TODO: UserDefaultsなどに完了状況保存 & 確認
        let realm = try! Realm(configuration: realmConfiguration)
        tasks.append(insertTwitterSessionIfNeed(realm))
        tasks.append(insertMastodonSessionIfNeed(realm))
        Observable.merge(tasks)
            .subscribe(onCompleted: {
                print("Done")
            })
            .disposed(by: disposeBag)
    }
}

extension VersionMigrations {

    private func insertTwitterSessionIfNeed(_ realm: Realm) -> Observable<Void> {
        return Observable<Void>.create { (observer) -> Disposable in
            // Twitterログインされていない OR Twitterログイン情報が1つ以上保存されている
            if !TwitterClient.shared.isLogin || !realm.objects(User.self).filter("serviceType = %@", Service.twitter.rawValue).isEmpty {
                observer.onCompleted()
                return Disposables.create()
            }

            guard let session = TWTRTwitter.sharedInstance().sessionStore.session() else {
                observer.onCompleted()
                return Disposables.create()
            }

            TWTRAPIClient.withCurrentUser().loadUser(withID: session.userID) { (user, error) in
                guard let user = user, error == nil else {
                    observer.onError(error!)
                    return
                }
                do {
                    let object = User(serviceID: user.userID, name: user.name, screenName: user.screenName, serviceType: .twitter)
                    let consumerKey = ProcessInfo.processInfo.get(forKey: .twitterConsumerKey)
                    let consumerSecret = ProcessInfo.processInfo.get(forKey: .twitterConsumerSecret)
                    let credential = SecretCredential(consumerKey: consumerKey, consumerSecret: consumerSecret,
                                                      authToken: session.authToken, authTokenSecret: session.authTokenSecret, user: object)
                    try realm.write {
                        realm.add(object, update: .error)
                        realm.add(credential, update: .error)
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    private func insertMastodonSessionIfNeed(_ realm: Realm) -> Observable<Void> {
        return Observable<Void>.create { [weak self] (observer) -> Disposable in
            guard let wself = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            // Mastodonログインされていない OR Mastodonログイン情報が1つ以上保存されている
            if !UserDefaults.bool(forKey: .isMastodonLogin) || !realm.objects(User.self).filter("serviceType = %@", Service.mastodon.rawValue).isEmpty {
                observer.onCompleted()
                return Disposables.create()
            }

            guard let hostname = UserDefaults.string(forKey: .mastodonHostname) else {
                observer.onCompleted()
                return Disposables.create()
            }
            Session.shared.rx.response(MastodonUpdateCredentialsRequest(hostname: hostname))
                .subscribe(onSuccess: { (response) in
                    let keychain = Keychain(service: keychainServiceKey)
                    guard let clientID = UserDefaults.string(forKey: .mastodonClientID),
                        let clientSecret = UserDefaults.string(forKey: .mastodonClientSecret),
                        let authorizationCode = keychain[KeychainKey.mastodonAccessToken.rawValue] else {
                            observer.onCompleted()
                            return
                    }
                    let user = User(serviceID: response.serviceID, name: response.displayName, screenName: response.username, serviceType: .mastodon)
                    let credential = SecretCredential(consumerKey: clientID, consumerSecret: clientSecret, authToken: authorizationCode,
                                                      domainName: hostname, user: user)
                    do {
                        try realm.write {
                            realm.add(user, update: .error)
                            realm.add(credential, update: .error)
                        }
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }, onError: { (error) in
                    observer.onError(error)
                })
                .disposed(by: wself.disposeBag)
            return Disposables.create()
        }
    }
}
