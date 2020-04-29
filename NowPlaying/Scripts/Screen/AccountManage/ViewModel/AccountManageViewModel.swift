//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxDataSources
import RxRealm
import RxSwift

protocol AccountManageViewModelInput {

    var addTrigger: PublishRelay<Void> { get }
    var editTrigger: PublishRelay<Void> { get }
    var deleteTrigger: PublishRelay<User> { get }
    var cellSelected: PublishRelay<User> { get }
}

protocol AccountManageViewModelOutput {

    var dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)> { get }
    var loginSuccess: Observable<String> { get }
    var loginError: Observable<String> { get }
}

protocol AccountManageViewModelType: AnyObject {

    var input: AccountManageViewModelInput { get }
    var output: AccountManageViewModelOutput { get }
    var service: Service { get }
    init(router: AccountManageRouter)
}

final class AccountManageViewModel: AccountManageViewModelType {

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
    private let accounts: BehaviorSubject<[User]> = .init(value: [])

    init(router: AccountManageRouter) {
        dataSource = .empty()
        loginSuccess = .empty()
        loginError = .empty()
    }
}

// MARK: - AccountManageViewModelInput

extension AccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
