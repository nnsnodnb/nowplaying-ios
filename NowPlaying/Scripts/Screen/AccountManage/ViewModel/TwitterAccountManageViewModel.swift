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
import RxDataSources
import RxSwift

final class TwitterAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let dataSources: Observable<[AccountManageSectionModel]>
    let service: Service = .twitter

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let accounts: BehaviorSubject<[User]> = .init(value: [])

    init(router: AccountManageRouter) {
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()

        let realm = try! Realm(configuration: realmConfiguration)

        let users = realm.objects(User.self).filter("serviceType = %@", service.rawValue)
        accounts.onNext(users.map { $0 })
    }
}

// MARK: - AccountManageViewModelInput

extension TwitterAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension TwitterAccountManageViewModel: AccountManageViewModelOutput {}
