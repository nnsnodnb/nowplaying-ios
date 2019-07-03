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

// MARK: - AccountManageViewModelOutput

protocol AccountManageViewModelOutput {

    var title: Observable<String> { get }
    var users: Observable<Results<User>> { get }
}

// MARK: - AccountManageViewModelType

protocol AccountManageViewModelType {

    var outputs: AccountManageViewModelOutput { get }
    var realm: Realm { get }

    init(service: Service)
}

final class AccountManageViewModel: AccountManageViewModelType {

    let realm: Realm = try! Realm(configuration: realmConfiguration)
    let title: Observable<String>
    let users: Observable<Results<User>>

    var outputs: AccountManageViewModelOutput { return self }

    init(service: Service) {
        switch service {
        case .twitter:
            title = Observable.just("Twitterアカウント")
        case .mastodon:
            title = Observable.just("Mastodonアカウント")
        }
        users = realm.objects(User.self)
            .filter("serviceType = %@", service.rawValue)
            .sorted(byKeyPath: "id", ascending: true)
            .response()
            .asObservable()
    }
}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
