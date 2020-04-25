//
//  TwitterAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Foundation
import RealmSwift
import RxCocoa
import RxDataSources
import RxRealm
import RxSwift
import SwifteriOS

final class TwitterAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let changeDefaultAccount: PublishRelay<User> = .init()
    let dataSources: Observable<[AccountManageSectionModel]>
    let loginSuccess: Observable<String>
    let loginError: Observable<String>
    let changedDefaultAccount: Observable<User>
    let service: Service = .twitter

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let router: AccountManageRouter
    private let accounts: BehaviorSubject<[User]> = .init(value: [])
    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)
    private let loginSuccessTrigger: PublishRelay<String> = .init()
    private let loginErrorTrigger: PublishRelay<Error> = .init()

    private lazy var fetchUsersAction: Action<Void, Results<User>> = .init {
        let realm = try! Realm(configuration: realmConfiguration)
        let users = realm.objects(User.self).filter("serviceType = %@", Service.twitter.rawValue)
        return Observable.collection(from: users, synchronousStart: true)
    }
    private lazy var changeDefaultAction: Action<User, User> = .init {
        return User.changeDefault(toUser: $0)
    }

    init(router: AccountManageRouter) {
        self.router = router
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()
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

        let newDefaultAccount: PublishRelay<User> = .init()
        changedDefaultAccount = newDefaultAccount.asObservable()

        addTrigger.bind(to: login).disposed(by: disposeBag)

        editTrigger
            .subscribe(onNext: {
                router.setEditing()
            })
            .disposed(by: disposeBag)

        changeDefaultAccount.bind(to: changeDefaultAction.inputs).disposed(by: disposeBag)

        fetchUsersAction.elements.map { $0.map { $0 } }.bind(to: accounts).disposed(by: disposeBag)
        fetchUsersAction.execute(())

        changeDefaultAction.elements.bind(to: newDefaultAccount).disposed(by: disposeBag)
    }

    private var login: Binder<Void> {
        return .init(self) { (base, _) in
            let onError: (Error) -> Void = { [weak base] (error) in
                base?.loginErrorTrigger.accept(error)
            }

            _ = base.router.login()
                .withLatestFrom(base.accounts) { ($0, $1) }
                .subscribe(onNext: { [weak base] (token, accounts) in
                    guard accounts.first(where: { $0.serviceID == token.userID }) == nil else {
                        // すでに登録されている
                        base?.loginErrorTrigger.accept(AuthError.alreadyUser)
                        return
                    }
                    let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret,
                                          oauthToken: token.key, oauthTokenSecret: token.secret)
                    _ = swifter.rx.showUser(tag: .id(token.userID))
                        .subscribe(onSuccess: { (twitterUser) in
                            let user = User(serviceID: twitterUser.userID, name: twitterUser.name, screenName: twitterUser.screenName,
                                            iconURLString: twitterUser.iconURLString, service: .twitter)
                            let secret = SecretCredential(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret,
                                                          authToken: token.key, authTokenSecret: token.secret, domainName: "", user: user)

                            let realm = try! Realm(configuration: realmConfiguration)
                            _ = Observable.from([user, secret])
                                .bind(to: realm.rx.add())

                            base?.loginSuccessTrigger.accept(user.screenName)

                        }, onError: onError)

                }, onError: onError)
        }
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
