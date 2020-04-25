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
import RxSwift

typealias AccountManageSectionModel = AnimatableSectionModel<String, User>

protocol AccountManageViewModelInput {

    var addTrigger: PublishRelay<Void> { get }
    var editTrigger: PublishRelay<Void> { get }
}

protocol AccountManageViewModelOutput {

    var dataSources: Observable<[AccountManageSectionModel]> { get }
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
    let dataSources: Observable<[AccountManageSectionModel]>
    let service: Service = .mastodon

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let accounts: BehaviorSubject<[User]> = .init(value: [])

    init(router: AccountManageRouter) {
        dataSources = accounts.map { [AccountManageSectionModel(model: "", items: $0)] }.asObservable()
    }
}

// MARK: - AccountManageViewModelInput

extension AccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
