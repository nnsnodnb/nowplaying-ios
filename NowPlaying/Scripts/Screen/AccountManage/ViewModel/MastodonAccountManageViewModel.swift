//
//  MastodonAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
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
    private let accounts: BehaviorSubject<[User]> = .init(value: [])

    init(router: AccountManageRoutable) {
        dataSource = .empty()
        loginSuccess = .empty()
        loginError = .empty()
    }
}

// MARK: - AccountManageViewModelInput

extension MastodonAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension MastodonAccountManageViewModel: AccountManageViewModelOutput {}
