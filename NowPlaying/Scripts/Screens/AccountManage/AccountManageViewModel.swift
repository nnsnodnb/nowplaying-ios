//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

struct AccountManageViewModelInput {

    let service: Service
    let addAccountBarButtonItem: Observable<Void>
    let editAccountsBarButtonItem: Observable<Void>
}

// MARK: - AccountManageViewModelOutput

protocol AccountManageViewModelOutput {

    var title: Observable<String> { get }
    var users: Observable<Results<User>> { get }
}

// MARK: - AccountManageViewModelType

protocol AccountManageViewModelType {

    var outputs: AccountManageViewModelOutput { get }
    var realm: Realm { get }

    init(inputs: AccountManageViewModelInput)
}

final class AccountManageViewModel: AccountManageViewModelType {

    let realm: Realm = try! Realm(configuration: realmConfiguration)
    let title: Observable<String>
    let users: Observable<Results<User>>

    var outputs: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(inputs: AccountManageViewModelInput) {
        switch inputs.service {
        case .twitter:
            title = Observable.just("Twitterアカウント")
        case .mastodon:
            title = Observable.just("Mastodonアカウント")
        }
        users = realm.objects(User.self)
            .filter("serviceType = %@", inputs.service.rawValue)
            .sorted(byKeyPath: "id", ascending: true)
            .response()
            .asObservable()

        subscribeBarButtonItems(inputs: inputs)
    }

    private func subscribeBarButtonItems(inputs: AccountManageViewModelInput) {
        inputs.addAccountBarButtonItem
            .subscribe(onNext: {
                switch inputs.service {
                case .twitter:
                    break
                case .mastodon:
                    break
                }
            })
            .disposed(by: disposeBag)

        inputs.editAccountsBarButtonItem
            .subscribe(onNext: {

            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
