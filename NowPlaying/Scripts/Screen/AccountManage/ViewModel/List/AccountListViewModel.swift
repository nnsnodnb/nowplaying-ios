//
//  AccountListViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/10.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

final class AccountListViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let deleteTrigger: PublishRelay<User> = .init()
    let cellSelected: PublishRelay<User> = .init()
    let dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)>
    let loginSuccess: Observable<String> = .empty()
    let loginError: Observable<String> = .empty()
    let service: Service

    var inputs: AccountManageViewModelInput { return self }
    var outputs: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: AccountManageRoutable, service: Service, handler: @escaping (User) -> Void) {
        self.service = service
        let realm = try! Realm(configuration: realmConfiguration)
        let results = realm.objects(User.self).filter("serviceType = %@", service.rawValue).sorted(byKeyPath: "id", ascending: true)
        dataSource = Observable.changeset(from: results)

        cellSelected
            .subscribe(onNext: {
                handler($0)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewModelInput

extension AccountListViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountListViewModel: AccountManageViewModelOutput {}
