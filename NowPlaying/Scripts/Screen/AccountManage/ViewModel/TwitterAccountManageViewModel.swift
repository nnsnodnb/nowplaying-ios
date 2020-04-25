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
import RxSwift
import SwifteriOS

final class TwitterAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let dataSources: Observable<[AccountManageSectionModel]>
    let service: Service = .twitter

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let router: AccountManageRouter
    private let accounts: BehaviorSubject<[User]> = .init(value: [])
    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret)

    private lazy var fetchUsersAction: Action<Service, [User]> = .init {
        let realm = try! Realm(configuration: realmConfiguration)
        return .just(realm.objects(User.self).filter("serviceType = %@", $0.rawValue).map { $0 })
    }

    init(router: AccountManageRouter) {
        self.router = router
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()

        addTrigger.bind(to: login).disposed(by: disposeBag)

        fetchUsersAction.elements.bind(to: accounts).disposed(by: disposeBag)
        fetchUsersAction.execute(service)
    }

    private var login: Binder<Void> {
        return .init(self) { (base, _) in
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
                            try! realm.write {
                                realm.add(user, update: .all)
                                realm.add(secret, update: .all)
                            }

                        }, onError: { (error) in
                            print(error)
                        })

                }, onError: { (error) in
                    print(error)
                })
        }
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
