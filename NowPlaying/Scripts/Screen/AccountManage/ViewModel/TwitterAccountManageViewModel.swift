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
    private let swifter = Swifter(consumerKey: Environments.twitterConsumerKey, consumerSecret: Environments.twitterConsumerSecret, appOnly: true)

    private lazy var loginAction: Action<Void, Credential.OAuthAccessToken> = .init { [unowned self] in
        return self.router.login()
    }

    init(router: AccountManageRouter) {
        self.router = router
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()

        addTrigger.bind(to: loginAction.inputs).disposed(by: disposeBag)

        loginAction.elements
            .subscribe(onNext: {
                print($0.key)
                print($0.secret)
            })
            .disposed(by: disposeBag)

        loginAction.errors
            .subscribe(onNext: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)

        let realm = try! Realm(configuration: realmConfiguration)

        let users = realm.objects(User.self).filter("serviceType = %@", service.rawValue)
        accounts.onNext(users.map { $0 })
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
