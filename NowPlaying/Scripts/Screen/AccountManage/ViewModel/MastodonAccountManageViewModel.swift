//
//  MastodonAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MastodonKit
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

final class MastodonAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let deleteTrigger: PublishRelay<User> = .init()
    let cellSelected: PublishRelay<User> = .init()
    let dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)>
    let loginSuccess: Observable<String>
    let loginError: Observable<String>
    let service: Service = .mastodon

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: AccountManageRoutable) {
        let realm = try! Realm(configuration: realmConfiguration)
        let results = realm.objects(User.self).filter("serviceType = %@", service.rawValue).sorted(byKeyPath: "id", ascending: true)
        dataSource = Observable.changeset(from: results)

        loginSuccess = .empty()
        loginError = .empty()

        addTrigger
            .subscribe(onNext: {
                _ = router.login()
                    .subscribe(onNext: { (accessToken) in
                        print(accessToken.key)
                    })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewModelInput

extension MastodonAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension MastodonAccountManageViewModel: AccountManageViewModelOutput {}
