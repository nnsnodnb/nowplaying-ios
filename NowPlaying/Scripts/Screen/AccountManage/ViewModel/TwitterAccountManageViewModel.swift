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
    let dataSources: Observable<[AccountManageSectionModel]>
    let loginError: Observable<Error>
    let service: Service = .twitter

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let router: AccountManageRouter
    private let accounts: BehaviorSubject<[User]> = .init(value: [])
    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)
    private let loginErrorTrigger: PublishRelay<Error> = .init()

    private lazy var fetchUsersAction: Action<Service, Results<User>> = .init {
        let realm = try! Realm(configuration: realmConfiguration)
        let users = realm.objects(User.self).filter("serviceType = %@", $0.rawValue)
        return Observable.collection(from: users, synchronousStart: true)
    }

    init(router: AccountManageRouter) {
        self.router = router
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()
        loginError = loginErrorTrigger.asObservable()

        addTrigger.bind(to: login).disposed(by: disposeBag)

        fetchUsersAction.elements.map { $0.map { $0 } }.bind(to: accounts).disposed(by: disposeBag)
        fetchUsersAction.execute(service)
    }

    private var login: Binder<Void> {
        return .init(self) { (base, _) in
            let onError: (Error) -> Void = { [weak base] (error) in
                base?.loginErrorTrigger.accept(error)
            }

            _ = base.router.login()
                .subscribe(onNext: { (token) in
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

                        }, onError: onError)

                }, onError: onError)
        }
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
