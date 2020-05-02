//
//  TwitterAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift
import SwifteriOS

final class TwitterAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let deleteTrigger: PublishRelay<User> = .init()
    let cellSelected: PublishRelay<User> = .init()
    let dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)>
    let loginSuccess: Observable<String>
    let loginError: Observable<String>
    let service: Service = .twitter

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let router: AccountManageRoutable
    private let loginSuccessTrigger: PublishRelay<String> = .init()
    private let loginErrorTrigger: PublishRelay<Error> = .init()

    init(router: AccountManageRoutable) {
        self.router = router

        let realm = try! Realm(configuration: realmConfiguration)
        let results = realm.objects(User.self).filter("serviceType = %@", service.rawValue).sorted(byKeyPath: "id", ascending: true)
        dataSource = Observable.changeset(from: results)

        loginSuccess = loginSuccessTrigger.map { "@\($0)" }.observeOn(MainScheduler.instance).asObservable()
        loginError = loginErrorTrigger.map { (error) -> String in
            if let authError = error as? AuthError {
                switch authError {
                case .cancel:
                    return "ログインをキャンセルしました"
                case .alreadyUser:
                    return "既にログインされているユーザです"
                case .unknown:
                    return "不明なエラーが発生しました: \(error.localizedDescription)"
                }
            } else {
                return "ログインエラーが発生しました"
            }
        }.observeOn(MainScheduler.instance).asObservable()

        addTrigger.bind(to: login).disposed(by: disposeBag)

        editTrigger
            .subscribe(onNext: {
                router.setEditing()
            })
            .disposed(by: disposeBag)

        deleteTrigger.map { $0.id }.bind(to: deleteUser).disposed(by: disposeBag)

        cellSelected
            .subscribe(onNext: { [unowned self] (user) in
                let realm = try! Realm(configuration: realmConfiguration)
                let others = realm.objects(User.self).filter("id != %@ AND serviceType = %@", user.id, self.service.rawValue)
                try! realm.write {
                    user.isDefault = true
                    others.setValue(false, forKey: "isDefault")
                }
            })
            .disposed(by: disposeBag)
    }

    private var login: Binder<Void> {
        return .init(self) { (base, _) in
            let onError: (Error) -> Void = { [weak base] (error) in
                base?.loginErrorTrigger.accept(error)
            }

            _ = base.router.login()
                .subscribe(onNext: { [weak base] (token) in
                    let realm = try! Realm(configuration: realmConfiguration)
                    guard realm.objects(User.self).filter("serviceID = %@ AND serviceType = %@", token.userID, "twitter").first == nil else {
                        // すでに登録されている
                        base?.loginErrorTrigger.accept(AuthError.alreadyUser)
                        return
                    }
                    let swifter = Swifter.nowPlaying(oauthToken: token.key, oauthTokenSecret: token.secret)
                    _ = swifter.rx.showUser(tag: .id(token.userID))
                        .subscribe(onSuccess: { (twitterUser) in
                            let user = User(serviceID: twitterUser.userID, name: twitterUser.name, screenName: twitterUser.screenName,
                                            iconURLString: twitterUser.iconURLString, service: .twitter)
                            let secret = SecretCredential.createTwitter(authToken: token.key, authTokenSecret: token.secret, user: user)

                            let realm = try! Realm(configuration: realmConfiguration)
                            try! realm.write {
                                realm.add(user, update: .error)
                                realm.add(secret, update: .error)
                            }

                            base?.loginSuccessTrigger.accept(user.screenName)

                        }, onError: onError)

                }, onError: onError)
        }
    }

    private var deleteUser: Binder<Int> {
        return .init(self) { (base, identifier) in
            let realm = try! Realm(configuration: realmConfiguration)
            guard let user = realm.object(ofType: User.self, forPrimaryKey: identifier) else { return }
            let secrets = user.secretCredentials

            let defaultUser: User?
            if user.isDefault {
                defaultUser = realm.objects(User.self).filter("id != %@ AND serviceType = %@", user.id, base.service.rawValue).first
            } else {
                defaultUser = nil
            }

            try! realm.write {
                realm.delete(secrets)
                realm.delete(user)
                defaultUser?.isDefault = true
            }

            if let newDefaultUser = defaultUser, newDefaultUser.isDefault {
                base.router.completeChangedDefaultAccount(user: newDefaultUser)
            }
        }
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
